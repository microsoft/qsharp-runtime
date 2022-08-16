// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

#include <cassert>
#include <unordered_map>

#include "QirRuntime.hpp"

#include "QirRuntimeApi_I.hpp"
#include "SimFactory.hpp"
#include "QirContext.hpp"
#include "QirTypes.hpp"

/*=============================================================================
    Note: QIR assumes a single global execution context!
=============================================================================*/

// QIR specification requires the Result type to be reference counted, even though Results are created by the target and
// qubits, created by the same target, aren't reference counted. To minimize the implementation burden on the target,
// the runtime will track the reference counts for results. The trade-off is the performance penalty of such external
// tracking. The design should be evaluated against real user code when we have it.
static std::unordered_map<RESULT*, int>& AllocatedResults()
{
    static std::unordered_map<RESULT*, int> allocatedResults;
    return allocatedResults;
}

static Microsoft::Quantum::IRestrictedAreaManagement* RestrictedAreaManagement()
{
    return dynamic_cast<Microsoft::Quantum::IRestrictedAreaManagement*>(
        Microsoft::Quantum::GlobalContext()->GetDriver());
}

extern "C"
{
    Result __quantum__rt__result_get_zero()
    {
        return Microsoft::Quantum::GlobalContext()->GetDriver()->UseZero();
    }

    Result __quantum__rt__result_get_one()
    {
        return Microsoft::Quantum::GlobalContext()->GetDriver()->UseOne();
    }

    QUBIT* __quantum__rt__qubit_allocate()
    {
        try
        {
            return reinterpret_cast<QUBIT*>(Microsoft::Quantum::GlobalContext()->GetDriver()->AllocateQubit());
        }
        catch (std::runtime_error& e)
        {
            __quantum__rt__fail(__quantum__rt__string_create(e.what()));
        }
    }

    QirArray* __quantum__rt__qubit_allocate_array(int64_t count)
    {
        try
        {
            QirArray* array = __quantum__rt__array_create_1d(sizeof(intptr_t), count);
            for (QirArray::TItemCount i = 0; i < count; i++)
            {
                *reinterpret_cast<QUBIT**>(__quantum__rt__array_get_element_ptr_1d(array, i)) =
                    __quantum__rt__qubit_allocate();
            }
            return array;
        }
        catch (std::runtime_error& e)
        {
            __quantum__rt__fail(__quantum__rt__string_create(e.what()));
        }
    }

    void __quantum__rt__qubit_release(QUBIT* qubit)
    {
        try
        {
            Microsoft::Quantum::GlobalContext()->GetDriver()->ReleaseQubit(reinterpret_cast<QubitIdType>(qubit));
        }
        catch (std::runtime_error& e)
        {
            __quantum__rt__fail(__quantum__rt__string_create(e.what()));
        }
    }

    void __quantum__rt__qubit_release_array(QirArray* array)
    {
        try
        {
            QirArray::TItemCount count = (QirArray::TItemCount)__quantum__rt__array_get_size_1d(array);
            for (QirArray::TItemCount i = 0; i < count; i++)
            {
                __quantum__rt__qubit_release(
                    *reinterpret_cast<QUBIT**>(__quantum__rt__array_get_element_ptr_1d(array, i)));
            }
            __quantum__rt__array_update_reference_count(array, -1);
        }
        catch (std::runtime_error& e)
        {
            __quantum__rt__fail(__quantum__rt__string_create(e.what()));
        }
    }

    QUBIT* __quantum__rt__qubit_borrow()
    {
        // Currently we implement borrowing as allocation.
        return __quantum__rt__qubit_allocate();
    }

    QirArray* __quantum__rt__qubit_borrow_array(int64_t count)
    {
        return __quantum__rt__qubit_allocate_array(count);
    }

    void __quantum__rt__qubit_return(QUBIT* qubit)
    {
        // Currently we implement borrowing as allocation.
        __quantum__rt__qubit_release(qubit);
    }

    void __quantum__rt__qubit_return_array(QirArray* array)
    {
        __quantum__rt__qubit_release_array(array);
    }

    void __quantum__rt__qubit_restricted_reuse_area_start()
    {
        try
        {
            RestrictedAreaManagement()->StartArea();
        }
        catch (std::runtime_error& e)
        {
            __quantum__rt__fail(__quantum__rt__string_create(e.what()));
        }
    }

    void __quantum__rt__qubit_restricted_reuse_segment_next()
    {
        try
        {
            RestrictedAreaManagement()->NextSegment();
        }
        catch (std::runtime_error& e)
        {
            __quantum__rt__fail(__quantum__rt__string_create(e.what()));
        }
    }

    void __quantum__rt__qubit_restricted_reuse_area_end()
    {
        try
        {
            RestrictedAreaManagement()->EndArea();
        }
        catch (std::runtime_error& e)
        {
            __quantum__rt__fail(__quantum__rt__string_create(e.what()));
        }
    }

    void __quantum__rt__result_update_reference_count(RESULT* r, int32_t increment)
    {
        if (increment == 0)
        {
            return; // Inefficient QIR? But no harm.
        }
        else if (increment > 0)
        {
            // If we don't have the result in our map, assume it has been allocated by a measurement with refcount = 1,
            // and this is the first attempt to share it.
            std::unordered_map<RESULT*, int>& trackedResults = AllocatedResults();
            auto rit                                         = trackedResults.find(r);
            if (rit == trackedResults.end())
            {
                trackedResults[r] = 1 + increment;
            }
            else
            {
                rit->second += increment;
            }
        }
        else
        {
            // If we don't have the result in our map, assume it has been never shared, so it's reference count is 1.
            std::unordered_map<RESULT*, int>& trackedResults = AllocatedResults();
            auto rit                                         = trackedResults.find(r);
            if (rit == trackedResults.end())
            {
                assert(increment == -1);
                Microsoft::Quantum::GlobalContext()->GetDriver()->ReleaseResult(r);
            }
            else
            {
                const int newRefcount = rit->second + increment;
                assert(newRefcount >= 0);
                if (newRefcount == 0)
                {
                    trackedResults.erase(rit);
                    Microsoft::Quantum::GlobalContext()->GetDriver()->ReleaseResult(r);
                }
                else
                {
                    rit->second = newRefcount;
                }
            }
        }
    }

    bool __quantum__rt__result_equal(RESULT* r1, RESULT* r2) // NOLINT
    {
        if (r1 == r2)
        {
            return true;
        }
        return Microsoft::Quantum::GlobalContext()->GetDriver()->AreEqualResults(r1, r2);
    }

    // Returns a string representation of the result.
    QirString* __quantum__rt__result_to_string(RESULT* result) // NOLINT
    {
        ResultValue rv = Microsoft::Quantum::GlobalContext()->GetDriver()->GetResultValue(result);
        assert(rv != Result_Pending);

        return (rv == Result_Zero) ? __quantum__rt__string_create("Zero") : __quantum__rt__string_create("One");
    }

    // Returns a string representation of the qubit.
    QirString* __quantum__rt__qubit_to_string(QUBIT* qubit) // NOLINT
    {
        return __quantum__rt__string_create(Microsoft::Quantum::GlobalContext()
                                                ->GetDriver()
                                                ->QubitToString(reinterpret_cast<QubitIdType>(qubit))
                                                .c_str());
    }

    void __quantum__rt__result_record_output(RESULT* result) // NOLINT
    {
        if (__quantum__rt__result_equal(result, __quantum__rt__result_get_one()))
        {
            __quantum__rt__message(__quantum__rt__string_create("RESULT\t1\n"));
        }
        else
        {
            __quantum__rt__message(__quantum__rt__string_create("RESULT\t0\n"));
        }
    }
}

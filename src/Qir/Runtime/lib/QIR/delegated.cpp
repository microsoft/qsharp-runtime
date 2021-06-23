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

extern "C"
{
    Result quantum__rt__result_get_zero()
    {
        return Microsoft::Quantum::GlobalContext()->GetDriver()->UseZero();
    }

    Result quantum__rt__result_get_one()
    {
        return Microsoft::Quantum::GlobalContext()->GetDriver()->UseOne();
    }

    QUBIT* quantum__rt__qubit_allocate() // NOLINT
    {
        return Microsoft::Quantum::GlobalContext()->GetDriver()->AllocateQubit();
    }

    void quantum__rt__qubit_release(QUBIT* qubit) // NOLINT
    {
        Microsoft::Quantum::GlobalContext()->GetDriver()->ReleaseQubit(qubit);
    }

    void quantum__rt__result_update_reference_count(RESULT* r, int32_t increment)
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
            auto rit = trackedResults.find(r);
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
            auto rit = trackedResults.find(r);
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

    bool quantum__rt__result_equal(RESULT* r1, RESULT* r2) // NOLINT
    {
        if (r1 == r2)
        {
            return true;
        }
        return Microsoft::Quantum::GlobalContext()->GetDriver()->AreEqualResults(r1, r2);
    }

    // Returns a string representation of the result.
    QirString* quantum__rt__result_to_string(RESULT* result) // NOLINT
    {
        ResultValue rv = Microsoft::Quantum::GlobalContext()->GetDriver()->GetResultValue(result);
        assert(rv != Result_Pending);

        return (rv == Result_Zero) ? quantum__rt__string_create("Zero") : quantum__rt__string_create("One");
    }

    // Returns a string representation of the qubit.
    QirString* quantum__rt__qubit_to_string(QUBIT* qubit) // NOLINT
    {
        return quantum__rt__string_create(Microsoft::Quantum::GlobalContext()->GetDriver()->QubitToString(qubit).c_str());
    }
}

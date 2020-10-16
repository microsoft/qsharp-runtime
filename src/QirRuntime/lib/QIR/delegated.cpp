/*=============================================================================
    QIR assumes a single global execution context.
    To support the dispatch over the qir-bridge, the clients must implement
    Microsoft::Quantum::IQuantumApi* g_qapi;
=============================================================================*/
#include <assert.h>
#include <unordered_map>

#include "__quantum__rt.hpp"

#include "IQuantumApi.hpp"
#include "qirTypes.hpp"

Microsoft::Quantum::IQuantumApi* g_qapi = nullptr;
extern "C" QIR_SHARED_API Result ResultOne = nullptr;
extern "C" QIR_SHARED_API Result ResultZero = nullptr;
namespace Microsoft
{
namespace Quantum
{
    void SetCurrentQuantumApiForQIR(IQuantumApi* qapi)
    {
        g_qapi = qapi;
        if (g_qapi != nullptr)
        {
            ResultOne = g_qapi->UseOne();
            ResultZero = g_qapi->UseZero();
        }
        else
        {
            ResultOne = nullptr;
            ResultZero = nullptr;
        }
    }
} // namespace Quantum
} // namespace Microsoft

std::unordered_map<RESULT*, int>& AllocatedResults()
{
    static std::unordered_map<RESULT*, int> allocatedResults;
    return allocatedResults;
}

extern "C"
{
    QUBIT* quantum__rt__qubit_allocate() // NOLINT
    {
        return g_qapi->AllocateQubit();
    }

    void quantum__rt__qubit_release(QUBIT* qubit) // NOLINT
    {
        g_qapi->ReleaseQubit(qubit);
    }

    // Increments the reference count of a Result pointer.
    void quantum__rt__result_reference(RESULT* r) // NOLINT
    {
        // If we don't have the result in our map, assume it has been allocated by a measurement with refcount = 1,
        // and this is the first attempt to share it.
        std::unordered_map<RESULT*, int>& trackedResults = AllocatedResults();
        auto rit = trackedResults.find(r);
        if (rit == trackedResults.end())
        {
            trackedResults[r] = 2;
        }
        else
        {
            rit->second += 1;
        }
    }

    // Decrements the reference count of a Result pointer and releases the result if appropriate.
    void quantum__rt__result_unreference(RESULT* r) // NOLINT
    {
        // If we don't have the result in our map, assume it has been never shared.
        std::unordered_map<RESULT*, int>& trackedResults = AllocatedResults();
        auto rit = trackedResults.find(r);
        if (rit == trackedResults.end())
        {
            g_qapi->ReleaseResult(r);
        }
        else
        {
            const int refcount = rit->second;
            assert(refcount > 0);
            if (refcount == 1)
            {
                trackedResults.erase(rit);
                g_qapi->ReleaseResult(r);
            }
            else
            {
                rit->second = refcount - 1;
            }
        }
    }

    bool quantum__rt__result_equal(RESULT* r1, RESULT* r2) // NOLINT
    {
        if (r1 == r2)
        {
            return true;
        }
        const TernaryBool res = g_qapi->AreEqualResults(r1, r2);
        assert(res != TernaryBool_Undefined);
        return res == TernaryBool_True;
    }

    // Returns a string representation of the result.
    QirString* quantum__rt__result_to_string(RESULT* result) // NOLINT
    {
        ResultValue rv = g_qapi->GetResultValue(result);
        assert(rv != Result_Pending);

        return (rv == Result_Zero) ? quantum__rt__string_create("Zero") : quantum__rt__string_create("One");
    }

    // Returns a string representation of the qubit.
    QirString* quantum__rt__qubit_to_string(QUBIT* qubit) // NOLINT
    {
        return quantum__rt__string_create(g_qapi->DumpQubit(qubit).c_str());
    }
}
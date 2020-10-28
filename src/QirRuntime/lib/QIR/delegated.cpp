// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

/*=============================================================================
    QIR assumes a single global execution context.
    To support the dispatch over the qir-bridge, the clients must implement
    Microsoft::Quantum::IQuantumApi* g_qapi;
=============================================================================*/
#include <assert.h>
#include <unordered_map>

#include "quantum__rt.hpp"

#include "QuantumApi_I.hpp"
#include "qirTypes.hpp"
#include "SimFactory.hpp"

Microsoft::Quantum::ISimulator* g_sim = nullptr;
extern "C" QIR_SHARED_API Result ResultOne = nullptr;
extern "C" QIR_SHARED_API Result ResultZero = nullptr;
namespace Microsoft
{
namespace Quantum
{
    void SetSimulatorForQIR(ISimulator* sim)
    {
        g_sim = sim;

        if (g_sim != nullptr)
        {
            ResultOne = g_sim->UseOne();
            ResultZero = g_sim->UseZero();
        }
        else
        {
            ResultOne = nullptr;
            ResultZero = nullptr;
        }
    }
} // namespace Quantum
} // namespace Microsoft

#ifdef _WIN32
#define EXPORTAPI extern "C" __declspec(dllexport)
#else
#define EXPORTAPI extern "C"
#endif
EXPORTAPI void SetupQirToRunOnFullStateSimulator()
{
    // Leak the simulator, because the QIR only creates one and it will exist for the duration of the session
    SetSimulatorForQIR(Microsoft::Quantum::CreateFullstateSimulator().release());
}

std::unordered_map<RESULT*, int>& AllocatedResults()
{
    static std::unordered_map<RESULT*, int> allocatedResults;
    return allocatedResults;
}

extern "C"
{
    Result UseZero()
    {
        return g_sim->UseZero();
    }

    Result UseOne()
    {
        return g_sim->UseOne();
    }

    QUBIT* quantum__rt__qubit_allocate() // NOLINT
    {
        return g_sim->AllocateQubit();
    }

    void quantum__rt__qubit_release(QUBIT* qubit) // NOLINT
    {
        g_sim->ReleaseQubit(qubit);
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
            g_sim->ReleaseResult(r);
        }
        else
        {
            const int refcount = rit->second;
            assert(refcount > 0);
            if (refcount == 1)
            {
                trackedResults.erase(rit);
                g_sim->ReleaseResult(r);
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
        const TernaryBool res = g_sim->AreEqualResults(r1, r2);
        assert(res != TernaryBool_Undefined);
        return res == TernaryBool_True;
    }

    // Returns a string representation of the result.
    QirString* quantum__rt__result_to_string(RESULT* result) // NOLINT
    {
        ResultValue rv = g_sim->GetResultValue(result);
        assert(rv != Result_Pending);

        return (rv == Result_Zero) ? quantum__rt__string_create("Zero") : quantum__rt__string_create("One");
    }

    // Returns a string representation of the qubit.
    QirString* quantum__rt__qubit_to_string(QUBIT* qubit) // NOLINT
    {
        return quantum__rt__string_create(g_sim->QubitToString(qubit).c_str());
    }
}
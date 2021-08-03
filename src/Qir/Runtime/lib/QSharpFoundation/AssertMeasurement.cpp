// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

#include "QirRuntime.hpp"
#include "QSharpSimApi_I.hpp"
#include "QirRuntimeApi_I.hpp"
#include "QirContext.hpp"

#include "qsharp__foundation__qis.hpp"

using namespace Microsoft::Quantum;

static IDiagnostics* GetDiagnostics()
{
    return dynamic_cast<IDiagnostics*>(GlobalContext()->GetDriver());
}

// Implementation:
extern "C"
{
    void quantum__qis__assertmeasurementprobability__body(
        QirArray* bases, QirArray* qubits, RESULT* result, double prob, QirString* msg, double tol)
    {
        if(bases->count != qubits->count)
        {
            quantum__rt__fail_cstr(
                "Both input arrays - bases, qubits - for AssertMeasurementProbability(), "
                "must be of same size.");
        }

        IRuntimeDriver *driver = GlobalContext()->GetDriver();
        if(driver->AreEqualResults(result, driver->UseOne()))
        {
            prob = 1.0 - prob;
        }

        // Convert paulis from sequence of bytes to sequence of PauliId:
        std::vector<PauliId> paulis(bases->count);
        for(QirArray::TItemCount i = 0; i < bases->count; ++i)
        {
            paulis[i] = (PauliId)*(bases->GetItemPointer(i));
        }

        if(!GetDiagnostics()->AssertProbability(
            (long)qubits->count, paulis.data(), reinterpret_cast<Qubit*>(qubits->GetItemPointer(0)), prob, tol, nullptr))
        {
            quantum__rt__fail(msg);
        }
    }

} // extern "C"

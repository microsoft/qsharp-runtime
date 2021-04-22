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
        if(driver->AreEqualResults(result, driver->UseZero()))
        {
            prob = 1.0 - prob;
        }
        if(!GetDiagnostics()->AssertProbability(
            (long)qubits->count, (PauliId*)(bases->buffer), (Qubit*)(qubits->buffer), prob, tol, nullptr))
        {
            quantum__rt__fail(msg);
        }
    }

} // extern "C"

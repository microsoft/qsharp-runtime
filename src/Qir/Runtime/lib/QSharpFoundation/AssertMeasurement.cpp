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
    void __quantum__qis__assertmeasurementprobability__body(QirArray* bases, QirArray* qubits, RESULT* result,
                                                            double prob, QirString* msg, double tol)
    {
        if (__quantum__rt__array_get_size_1d(bases) != __quantum__rt__array_get_size_1d(qubits))
        {
            __quantum__rt__fail_cstr("Both input arrays - bases, qubits - for AssertMeasurementProbability(), "
                                     "must be of same size.");
        }

        IRuntimeDriver* driver = GlobalContext()->GetDriver();
        if (driver->AreEqualResults(result, driver->UseOne()))
        {
            prob = 1.0 - prob;
        }

        // Convert paulis from sequence of bytes to sequence of PauliId:
        std::vector<PauliId> paulis((uint64_t)__quantum__rt__array_get_size_1d(bases));
        for (QirArray::TItemCount i = 0; i < __quantum__rt__array_get_size_1d(bases); ++i)
        {
            paulis[i] = (PauliId)*__quantum__rt__array_get_element_ptr_1d(bases, i);
        }

        if (!GetDiagnostics()->AssertProbability(
                (long)__quantum__rt__array_get_size_1d(qubits), paulis.data(),
                reinterpret_cast<QubitIdType*>(__quantum__rt__array_get_element_ptr_1d(qubits, 0)), prob, tol, nullptr))
        {
            __quantum__rt__fail_cstr(__quantum__rt__string_get_data(msg));
        }
    }

    void __quantum__qis__assertmeasurementprobability__ctl(QirArray* /* ctls */,
                                                           QirAssertMeasurementProbabilityTuple* args)
    {
        // Controlled AssertMeasurementProbability ignores control bits. See the discussion on
        // https://github.com/microsoft/qsharp-runtime/pull/450 for more details.
        __quantum__qis__assertmeasurementprobability__body(args->bases, args->qubits, args->result, args->prob,
                                                           args->msg, args->tol);
    }

} // extern "C"

// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

#include "QirRuntime.hpp"
#include "QSharpSimApi_I.hpp"
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
    // void quantum__qis__assertmeasurement__body(QirArray* bases, QirArray* qubits, RESULT* result, QirString* msg)
    // {
    //     if(bases->count != qubits->count)
    //     {
    //         quantum__rt__fail_cstr("Both input arrays - bases, qubits - "
    //             "for AssertMeasurement(), must be of same size.");
    //     }

    //     if(!GetDiagnostics()->Assert(
    //         (long)qubits->count, (PauliId*)(bases->buffer), (Qubit*)(qubits->buffer), result, nullptr))
    //     {
    //         quantum__rt__fail(msg);
    //     }
    // }

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

    /*
        bool AssertProbability(
            long numTargets,
            PauliId bases[],
            Qubit targets[],
            double probabilityOfZero,
            double precision,
            const char* failureMessage) override
        {
            typedef double (*TOp)(unsigned id, unsigned n, int* b, unsigned* q);
            static TOp jointEnsembleProbability = reinterpret_cast<TOp>(this->GetProc("JointEnsembleProbability"));

            vector<unsigned> ids = GetQubitIds(numTargets, targets);
            double actualProbability =
                1.0 -
                jointEnsembleProbability(this->simulatorId, numTargets, reinterpret_cast<int*>(bases), ids.data());

            return (std::abs(actualProbability - probabilityOfZero) < precision);
        }

        bool Assert(long numTargets, PauliId* bases, Qubit* targets, Result result, const char* failureMessage) override
        {
            const double probabilityOfZero = AreEqualResults(result, UseZero()) ? 1.0 : 0.0;
            return AssertProbability(numTargets, bases, targets, probabilityOfZero, 1e-10, failureMessage);
        }
    */

    /*
        var tolerance = 1.0e-10;
        var expectedPr = result == Result.Zero ? 0.0 : 1.0;

        var ensemblePr = JointEnsembleProbability(this.Simulator.Id, (uint)paulis.Length, paulis.ToArray(), qubits.GetIds());
        
        if (Abs(ensemblePr - expectedPr) > tolerance)
        {
            var extendedMsg = $"{msg}\n\tExpected:\t{expectedPr}\n\tActual:\t{ensemblePr}";
            IgnorableAssert.Assert(false, extendedMsg);
            throw new ExecutionFailException(extendedMsg);
        }

        return QVoid.Instance;
    */

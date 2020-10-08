#pragma once

#include <complex>

#include "CoreTypes.hpp"

namespace quantum
{
    struct IQuantumApi
    {
        virtual ~IQuantumApi() {}

        // TODO: Only some simulators 'know' the state -- is it OK to have this method on IQuantumApi?
        // The callback will be invoked on each basis vector (in the standard computational basis) in little-endian
        // order until it returns `false` or the state is fully dumped.
        typedef bool (*TGetStateCallback)(size_t /*basis vector*/, double /* amplitude Re*/, double /* amplitude Im*/);
        virtual void GetState(TGetStateCallback callback) = 0;

        virtual std::string DumpQubit(Qubit qubit) = 0;

        // Qubit management
        virtual Qubit AllocateQubit() = 0;
        virtual void ReleaseQubit(Qubit qubit) = 0;

        // Shortcuts
        virtual void CNOT(Qubit control, Qubit target)
        {
            CX(control, target);
        }
        virtual void CX(Qubit control, Qubit target) = 0;
        virtual void CY(Qubit control, Qubit target) = 0;
        virtual void CZ(Qubit control, Qubit target) = 0;

        // Elementary operatons
        virtual void X(Qubit target) = 0;
        virtual void Y(Qubit target) = 0;
        virtual void Z(Qubit target) = 0;
        virtual void H(Qubit target) = 0;
        virtual void S(Qubit target) = 0;
        virtual void T(Qubit target) = 0;
        virtual void SWAP(Qubit target1, Qubit target2) = 0;
        virtual void Clifford(CliffordId cliffordId, PauliId pauli, Qubit target) = 0;
        // unitary is an array of columns: 2^n x 2^n. Columns are nullable, so for state prep use just the first column
        virtual void Unitary(long numTargets, double** unitary, Qubit targets[]) = 0;

        virtual void Reset(Qubit target) = 0;

        virtual void R(PauliId axis, Qubit target, double theta) = 0;
        virtual void RFraction(PauliId axis, Qubit target, long numerator, long power) = 0;
        virtual void R1(Qubit target, double theta) = 0;
        virtual void R1Fraction(Qubit target, long numerator, long power) = 0;
        virtual void Exp(long numTargets, PauliId paulis[], Qubit targets[], double theta) = 0;
        virtual void ExpFraction(long numTargets, PauliId paulis[], Qubit targets[], long numerator, long power) = 0;

        // Multicontrolled operations
        virtual void ControlledX(long numControls, Qubit controls[], Qubit target) = 0;
        virtual void ControlledY(long numControls, Qubit controls[], Qubit target) = 0;
        virtual void ControlledZ(long numControls, Qubit controls[], Qubit target) = 0;
        virtual void ControlledH(long numControls, Qubit controls[], Qubit target) = 0;
        virtual void ControlledS(long numControls, Qubit controls[], Qubit target) = 0;
        virtual void ControlledT(long numControls, Qubit controls[], Qubit target) = 0;
        virtual void ControlledSWAP(long numControls, Qubit controls[], Qubit target1, Qubit target2) = 0;
        virtual void ControlledClifford(
            long numControls,
            Qubit controls[],
            CliffordId cliffordId,
            PauliId pauli,
            Qubit target) = 0;
        virtual void ControlledUnitary(
            long numControls,
            Qubit controls[],
            long numTargets,
            double** unitary,
            Qubit targets[]) = 0;

        virtual void ControlledR(long numControls, Qubit controls[], PauliId axis, Qubit target, double theta) = 0;
        virtual void ControlledRFraction(
            long numControls,
            Qubit controls[],
            PauliId axis,
            Qubit target,
            long numerator,
            long power) = 0;
        virtual void ControlledR1(long numControls, Qubit controls[], Qubit target, double theta) = 0;
        virtual void ControlledR1Fraction(
            long numControls,
            Qubit controls[],
            Qubit target,
            long numerator,
            long power) = 0;
        virtual void ControlledExp(
            long numControls,
            Qubit controls[],
            long numTargets,
            PauliId paulis[],
            Qubit targets[],
            double theta) = 0;
        virtual void ControlledExpFraction(
            long numControls,
            Qubit controls[],
            long numTargets,
            PauliId paulis[],
            Qubit targets[],
            long numerator,
            long power) = 0;

        // Adjoint operations
        virtual void SAdjoint(Qubit target) = 0;
        virtual void TAdjoint(Qubit target) = 0;
        virtual void ControlledSAdjoint(long numControls, Qubit controls[], Qubit target) = 0;
        virtual void ControlledTAdjoint(long numControls, Qubit controls[], Qubit target) = 0;

        // Both Assert methods return `true`, if the assert holds, `false` otherwise.
        virtual bool Assert(
            long numTargets,
            PauliId bases[],
            Qubit targets[],
            Result result,
            const char* failureMessage) = 0;
        virtual bool AssertProbability(
            long numTargets,
            PauliId bases[],
            Qubit targets[],
            double probabilityOfZero,
            double precision,
            const char* failureMessage) = 0;

        // Results
        virtual Result M(Qubit target) = 0;
        virtual Result Measure(long numBases, PauliId bases[], long numTargets, Qubit targets[]) = 0;
        virtual void ReleaseResult(Result result) = 0;
        virtual TernaryBool AreEqualResults(Result r1, Result r2) = 0;
        virtual ResultValue GetResultValue(Result result) = 0;
        // The caller *should not* release results obtained via these two methods. The
        // results are guaranteed to be finalized to the corresponding ResultValue, but
        // it's not required from the runtime to return same Result on subsequent calls.
        virtual Result UseZero() = 0;
        virtual Result UseOne() = 0;
    };

    void SetCurrentQuantumApiForQIR(quantum::IQuantumApi* qapi);
    
} // namespace quantum

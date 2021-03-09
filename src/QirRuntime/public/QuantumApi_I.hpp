#pragma once

#include <complex>

#include "CoreTypes.hpp"

namespace Microsoft
{
namespace Quantum
{
    struct IQuantumGateSet
    {
        virtual ~IQuantumGateSet() {}

        // Elementary operatons
        virtual void X(Qubit target) = 0;
        virtual void Y(Qubit target) = 0;
        virtual void Z(Qubit target) = 0;
        virtual void H(Qubit target) = 0;
        virtual void S(Qubit target) = 0;
        virtual void T(Qubit target) = 0;
        virtual void R(PauliId axis, Qubit target, double theta) = 0;
        virtual void Exp(long numTargets, PauliId paulis[], Qubit targets[], double theta) = 0;

        // Multicontrolled operations
        virtual void ControlledX(long numControls, Qubit controls[], Qubit target) = 0;
        virtual void ControlledY(long numControls, Qubit controls[], Qubit target) = 0;
        virtual void ControlledZ(long numControls, Qubit controls[], Qubit target) = 0;
        virtual void ControlledH(long numControls, Qubit controls[], Qubit target) = 0;
        virtual void ControlledS(long numControls, Qubit controls[], Qubit target) = 0;
        virtual void ControlledT(long numControls, Qubit controls[], Qubit target) = 0;
        virtual void ControlledR(long numControls, Qubit controls[], PauliId axis, Qubit target, double theta) = 0;
        virtual void ControlledExp(
            long numControls,
            Qubit controls[],
            long numTargets,
            PauliId paulis[],
            Qubit targets[],
            double theta) = 0;

        // Adjoint operations
        virtual void AdjointS(Qubit target) = 0;
        virtual void AdjointT(Qubit target) = 0;
        virtual void ControlledAdjointS(long numControls, Qubit controls[], Qubit target) = 0;
        virtual void ControlledAdjointT(long numControls, Qubit controls[], Qubit target) = 0;
    };

    struct IDiagnostics
    {
        virtual ~IDiagnostics() {}

        // The callback should be invoked on each basis vector (in the standard computational basis) in little-endian
        // order until it returns `false` or the state is fully dumped.
        typedef bool (*TGetStateCallback)(size_t /*basis vector*/, double /* amplitude Re*/, double /* amplitude Im*/);
        virtual void GetState(TGetStateCallback callback, long numQubits = 0, Qubit qubits[] = nullptr) = 0;

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
    };

    struct ISimulator
    {
        virtual ~ISimulator() {}

        // The caller is responsible for never accessing the returned pointer beyond the lifetime of the source
        // ISimulator instance.
        virtual IQuantumGateSet* AsQuantumGateSet() = 0;

        // Might return nullptr if the simulator doesn't support diagnostics. The caller is responsible for never
        // accessing the returned pointer beyond the lifetime of the source ISimulator instance.
        virtual IDiagnostics* AsDiagnostics() = 0;

        // Doesn't necessarily provide insight into the state of the qubit (for that look at IDiagnostics)
        virtual std::string QubitToString(Qubit qubit) = 0;

        // Qubit management
        virtual Qubit AllocateQubit() = 0;
        virtual void ReleaseQubit(Qubit qubit) = 0;

        // Results
        virtual Result M(Qubit target) = 0;
        virtual Result Measure(long numBases, PauliId bases[], long numTargets, Qubit targets[]) = 0;

        virtual void ReleaseResult(Result result) = 0;
        virtual bool AreEqualResults(Result r1, Result r2) = 0;
        virtual ResultValue GetResultValue(Result result) = 0;
        // The caller *should not* release results obtained via these two methods. The
        // results are guaranteed to be finalized to the corresponding ResultValue, but
        // it's not required from the runtime to return same Result on subsequent calls.
        virtual Result UseZero() = 0;
        virtual Result UseOne() = 0;
    };

} // namespace Quantum
} // namespace Microsoft

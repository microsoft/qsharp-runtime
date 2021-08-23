// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

#pragma once

#include <complex>

#include "CoreTypes.hpp"
#include "QirTypes.hpp"

namespace Microsoft
{
namespace Quantum
{
    struct QIR_SHARED_API IQuantumGateSet
    {
        virtual ~IQuantumGateSet()
        {
        }
        IQuantumGateSet() = default;

        // Elementary operatons
        virtual void X(qubitid_t target)                                                       = 0;
        virtual void Y(qubitid_t target)                                                       = 0;
        virtual void Z(qubitid_t target)                                                       = 0;
        virtual void H(qubitid_t target)                                                       = 0;
        virtual void S(qubitid_t target)                                                       = 0;
        virtual void T(qubitid_t target)                                                       = 0;
        virtual void R(PauliId axis, qubitid_t target, double theta)                           = 0;
        virtual void Exp(long numTargets, PauliId paulis[], qubitid_t targets[], double theta) = 0;

        // Multicontrolled operations
        virtual void ControlledX(long numControls, qubitid_t controls[], qubitid_t target) = 0;
        virtual void ControlledY(long numControls, qubitid_t controls[], qubitid_t target) = 0;
        virtual void ControlledZ(long numControls, qubitid_t controls[], qubitid_t target) = 0;
        virtual void ControlledH(long numControls, qubitid_t controls[], qubitid_t target) = 0;
        virtual void ControlledS(long numControls, qubitid_t controls[], qubitid_t target) = 0;
        virtual void ControlledT(long numControls, qubitid_t controls[], qubitid_t target) = 0;
        virtual void ControlledR(long numControls, qubitid_t controls[], PauliId axis, qubitid_t target,
                                 double theta)                                             = 0;
        virtual void ControlledExp(long numControls, qubitid_t controls[], long numTargets, PauliId paulis[],
                                   qubitid_t targets[], double theta)                      = 0;

        // Adjoint operations
        virtual void AdjointS(qubitid_t target)                                                   = 0;
        virtual void AdjointT(qubitid_t target)                                                   = 0;
        virtual void ControlledAdjointS(long numControls, qubitid_t controls[], qubitid_t target) = 0;
        virtual void ControlledAdjointT(long numControls, qubitid_t controls[], qubitid_t target) = 0;

        // Results
        virtual Result Measure(long numBases, PauliId bases[], long numTargets, qubitid_t targets[]) = 0;

      private:
        IQuantumGateSet& operator=(const IQuantumGateSet&) = delete;
        IQuantumGateSet(const IQuantumGateSet&)            = delete;
    };

    struct QIR_SHARED_API IDiagnostics
    {
        virtual ~IDiagnostics()
        {
        }
        IDiagnostics() = default;

        // The callback should be invoked on each basis vector (in the standard computational basis) in little-endian
        // order until it returns `false` or the state is fully dumped.
        typedef bool (*TGetStateCallback)(size_t /*basis vector*/, double /* amplitude Re*/, double /* amplitude Im*/);

        // Deprecated, use `DumpMachine()` and `DumpRegister()` instead.
        virtual void GetState(TGetStateCallback callback) = 0;

        virtual void DumpMachine(const void* location)                          = 0;
        virtual void DumpRegister(const void* location, const QirArray* qubits) = 0;

        // Both Assert methods return `true`, if the assert holds, `false` otherwise.
        virtual bool Assert(long numTargets, PauliId bases[], qubitid_t targets[], Result result,
                            const char* failureMessage) = 0; // TODO: The `failureMessage` is not used, consider
                                                             // removing. The `bool` is returned.

        virtual bool AssertProbability(long numTargets, PauliId bases[], qubitid_t targets[], double probabilityOfZero,
                                       double precision,
                                       const char* failureMessage) = 0; // TODO: The `failureMessage` is not used,
                                                                        // consider removing. The `bool` is returned.

      private:
        IDiagnostics& operator=(const IDiagnostics&) = delete;
        IDiagnostics(const IDiagnostics&)            = delete;
    };

} // namespace Quantum
} // namespace Microsoft

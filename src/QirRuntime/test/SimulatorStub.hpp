#pragma once

#include <exception>

#include "QuantumApi_I.hpp"

namespace Microsoft
{
namespace Quantum
{
    struct SimulatorStub : public ISimulator, public IQuantumGateSet
    {
        IQuantumGateSet* AsQuantumGateSet() override
        {
            return this;
        }
        IDiagnostics* AsDiagnostics() override
        {
            return nullptr;
        }
        Qubit AllocateQubit() override
        {
            throw std::logic_error("not_implemented");
        }
        void ReleaseQubit(Qubit qubit) override
        {
            throw std::logic_error("not_implemented");
        }
        virtual std::string QubitToString(Qubit qubit) override
        {
            throw std::logic_error("not_implemented");
        }
        void X(Qubit target) override
        {
            throw std::logic_error("not_implemented");
        }
        void Y(Qubit target) override
        {
            throw std::logic_error("not_implemented");
        }
        void Z(Qubit target) override
        {
            throw std::logic_error("not_implemented");
        }
        void H(Qubit target) override
        {
            throw std::logic_error("not_implemented");
        }
        void S(Qubit target) override
        {
            throw std::logic_error("not_implemented");
        }
        void T(Qubit target) override
        {
            throw std::logic_error("not_implemented");
        }
        void R(PauliId axis, Qubit target, double theta) override
        {
            throw std::logic_error("not_implemented");
        }
        void Exp(long numTargets, PauliId paulis[], Qubit targets[], double theta) override
        {
            throw std::logic_error("not_implemented");
        }
        void ControlledX(long numControls, Qubit controls[], Qubit target) override
        {
            throw std::logic_error("not_implemented");
        }
        void ControlledY(long numControls, Qubit controls[], Qubit target) override
        {
            throw std::logic_error("not_implemented");
        }
        void ControlledZ(long numControls, Qubit controls[], Qubit target) override
        {
            throw std::logic_error("not_implemented");
        }
        void ControlledH(long numControls, Qubit controls[], Qubit target) override
        {
            throw std::logic_error("not_implemented");
        }
        void ControlledS(long numControls, Qubit controls[], Qubit target) override
        {
            throw std::logic_error("not_implemented");
        }
        void ControlledT(long numControls, Qubit controls[], Qubit target) override
        {
            throw std::logic_error("not_implemented");
        }
        void ControlledR(long numControls, Qubit controls[], PauliId axis, Qubit target, double theta) override
        {
            throw std::logic_error("not_implemented");
        }
        void ControlledExp(
            long numControls,
            Qubit controls[],
            long numTargets,
            PauliId paulis[],
            Qubit targets[],
            double theta) override
        {
            throw std::logic_error("not_implemented");
        }
        void SAdjoint(Qubit target) override
        {
            throw std::logic_error("not_implemented");
        }
        void TAdjoint(Qubit target) override
        {
            throw std::logic_error("not_implemented");
        }
        void ControlledSAdjoint(long numControls, Qubit controls[], Qubit target) override
        {
            throw std::logic_error("not_implemented");
        }
        void ControlledTAdjoint(long numControls, Qubit controls[], Qubit target) override
        {
            throw std::logic_error("not_implemented");
        }
        Result M(Qubit target) override
        {
            throw std::logic_error("not_implemented");
        }
        Result Measure(long numBases, PauliId bases[], long numTargets, Qubit targets[]) override
        {
            throw std::logic_error("not_implemented");
        }
        void ReleaseResult(Result result) override
        {
            throw std::logic_error("not_implemented");
        }
        bool AreEqualResults(Result r1, Result r2) override
        {
            throw std::logic_error("not_implemented");
        }
        ResultValue GetResultValue(Result result) override
        {
            throw std::logic_error("not_implemented");
        }
        Result UseZero() override
        {
            throw std::logic_error("not_implemented");
        }
        Result UseOne() override
        {
            throw std::logic_error("not_implemented");
        }
    };

} // namespace Quantum
} // namespace Microsoft
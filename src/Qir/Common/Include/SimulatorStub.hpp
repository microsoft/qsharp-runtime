#pragma once

#include <exception>

#include "QirRuntimeApi_I.hpp"
#include "QSharpSimApi_I.hpp"

namespace Microsoft
{
namespace Quantum
{
    struct SimulatorStub : public IRuntimeDriver, public IQuantumGateSet
    {
        Qubit AllocateQubit() override
        {
            throw std::logic_error("not_implemented: AllocateQubit");
        }
        void ReleaseQubit(Qubit /* qubit */) override
        {
            throw std::logic_error("not_implemented: ReleaseQubit");
        }
        virtual std::string QubitToString(Qubit /* qubit */) override
        {
            throw std::logic_error("not_implemented: QubitToString");
        }
        void X(Qubit /*target*/) override
        {
            throw std::logic_error("not_implemented: X");
        }
        void Y(Qubit /*target*/) override
        {
            throw std::logic_error("not_implemented: Y");
        }
        void Z(Qubit /* target */) override
        {
            throw std::logic_error("not_implemented: Z");
        }
        void H(Qubit /*target*/) override
        {
            throw std::logic_error("not_implemented: H");
        }
        void S(Qubit /*target*/) override
        {
            throw std::logic_error("not_implemented: S");
        }
        void T(Qubit /*target*/) override
        {
            throw std::logic_error("not_implemented: T");
        }
        void R(PauliId /* axis */, Qubit /* target */, double /* theta */) override
        {
            throw std::logic_error("not_implemented: R");
        }
        void Exp(long /* numTargets */, PauliId* /* paulis */, Qubit* /* targets */, double /* theta */) override
        {
            throw std::logic_error("not_implemented: Exp");
        }
        void ControlledX(long /*numControls*/, Qubit* /*controls*/, Qubit /*target*/) override
        {
            throw std::logic_error("not_implemented: ControlledX");
        }
        void ControlledY(long /*numControls*/, Qubit* /*controls*/, Qubit /*target*/) override
        {
            throw std::logic_error("not_implemented: ControlledY");
        }
        void ControlledZ(long /*numControls*/, Qubit* /*controls*/, Qubit /*target*/) override
        {
            throw std::logic_error("not_implemented: ControlledZ");
        }
        void ControlledH(long /*numControls*/, Qubit* /*controls*/, Qubit /*target*/) override
        {
            throw std::logic_error("not_implemented: ControlledH");
        }
        void ControlledS(long /*numControls*/, Qubit* /*controls*/, Qubit /*target*/) override
        {
            throw std::logic_error("not_implemented: ControlledS");
        }
        void ControlledT(long /*numControls*/, Qubit* /*controls*/, Qubit /*target*/) override
        {
            throw std::logic_error("not_implemented: ControlledT");
        }
        void ControlledR(long /*numControls*/, Qubit* /*controls*/, PauliId /*axis*/, Qubit /*target*/, double /*theta*/) override
        {
            throw std::logic_error("not_implemented: ControlledR");
        }
        void ControlledExp(
            long /*numControls*/,
            Qubit* /*controls*/,
            long /*numTargets*/,
            PauliId* /*paulis*/,
            Qubit* /*targets*/,
            double /*theta*/) override
        {
            throw std::logic_error("not_implemented: ControlledExp");
        }
        void AdjointS(Qubit /*target*/) override
        {
            throw std::logic_error("not_implemented: AdjointS");
        }
        void AdjointT(Qubit /*target*/) override
        {
            throw std::logic_error("not_implemented: AdjointT");
        }
        void ControlledAdjointS(long /*numControls*/, Qubit* /*controls*/, Qubit /*target*/) override
        {
            throw std::logic_error("not_implemented: ControlledAdjointS");
        }
        void ControlledAdjointT(long /*numControls*/, Qubit* /*controls*/, Qubit /*target*/) override
        {
            throw std::logic_error("not_implemented: ControlledAdjointT");
        }
        Result Measure(long /*numBases*/, PauliId* /*bases*/, long /*numTargets*/, Qubit* /*targets*/) override
        {
            throw std::logic_error("not_implemented: Measure");
        }
        void ReleaseResult(Result /*result*/) override
        {
            throw std::logic_error("not_implemented: ReleaseResult");
        }
        bool AreEqualResults(Result /*r1*/, Result /*r2*/) override
        {
            throw std::logic_error("not_implemented: AreEqualResults");
        }
        ResultValue GetResultValue(Result /*result*/) override
        {
            throw std::logic_error("not_implemented: GetResultValue");
        }
        Result UseZero() override
        {
            throw std::logic_error("not_implemented: UseZero");
        }
        Result UseOne() override
        {
            throw std::logic_error("not_implemented: UseOne");
        }
    };

} // namespace Quantum
} // namespace Microsoft

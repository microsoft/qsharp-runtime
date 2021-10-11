#pragma once

#include <exception>

#include "QirRuntimeApi_I.hpp"
#include "QSharpSimApi_I.hpp"

namespace Microsoft
{
namespace Quantum
{
    struct SimulatorStub
        : public IRuntimeDriver
        , public IQuantumGateSet
    {
        QubitIdType AllocateQubit() override
        {
            throw std::logic_error("not_implemented: AllocateQubit");
        }
        void ReleaseQubit(QubitIdType /* qubit */) override
        {
            throw std::logic_error("not_implemented: ReleaseQubit");
        }
        virtual std::string QubitToString(QubitIdType /* qubit */) override
        {
            throw std::logic_error("not_implemented: QubitToString");
        }
        void X(QubitIdType /*target*/) override
        {
            throw std::logic_error("not_implemented: X");
        }
        void Y(QubitIdType /*target*/) override
        {
            throw std::logic_error("not_implemented: Y");
        }
        void Z(QubitIdType /* target */) override
        {
            throw std::logic_error("not_implemented: Z");
        }
        void H(QubitIdType /*target*/) override
        {
            throw std::logic_error("not_implemented: H");
        }
        void S(QubitIdType /*target*/) override
        {
            throw std::logic_error("not_implemented: S");
        }
        void T(QubitIdType /*target*/) override
        {
            throw std::logic_error("not_implemented: T");
        }
        void R(PauliId /* axis */, QubitIdType /* target */, double /* theta */) override
        {
            throw std::logic_error("not_implemented: R");
        }
        void Exp(long /* numTargets */, PauliId* /* paulis */, QubitIdType* /* targets */, double /* theta */) override
        {
            throw std::logic_error("not_implemented: Exp");
        }
        void ControlledX(long /*numControls*/, QubitIdType* /*controls*/, QubitIdType /*target*/) override
        {
            throw std::logic_error("not_implemented: ControlledX");
        }
        void ControlledY(long /*numControls*/, QubitIdType* /*controls*/, QubitIdType /*target*/) override
        {
            throw std::logic_error("not_implemented: ControlledY");
        }
        void ControlledZ(long /*numControls*/, QubitIdType* /*controls*/, QubitIdType /*target*/) override
        {
            throw std::logic_error("not_implemented: ControlledZ");
        }
        void ControlledH(long /*numControls*/, QubitIdType* /*controls*/, QubitIdType /*target*/) override
        {
            throw std::logic_error("not_implemented: ControlledH");
        }
        void ControlledS(long /*numControls*/, QubitIdType* /*controls*/, QubitIdType /*target*/) override
        {
            throw std::logic_error("not_implemented: ControlledS");
        }
        void ControlledT(long /*numControls*/, QubitIdType* /*controls*/, QubitIdType /*target*/) override
        {
            throw std::logic_error("not_implemented: ControlledT");
        }
        void ControlledR(long /*numControls*/, QubitIdType* /*controls*/, PauliId /*axis*/, QubitIdType /*target*/,
                         double /*theta*/) override
        {
            throw std::logic_error("not_implemented: ControlledR");
        }
        void ControlledExp(long /*numControls*/, QubitIdType* /*controls*/, long /*numTargets*/, PauliId* /*paulis*/,
                           QubitIdType* /*targets*/, double /*theta*/) override
        {
            throw std::logic_error("not_implemented: ControlledExp");
        }
        void AdjointS(QubitIdType /*target*/) override
        {
            throw std::logic_error("not_implemented: AdjointS");
        }
        void AdjointT(QubitIdType /*target*/) override
        {
            throw std::logic_error("not_implemented: AdjointT");
        }
        void ControlledAdjointS(long /*numControls*/, QubitIdType* /*controls*/, QubitIdType /*target*/) override
        {
            throw std::logic_error("not_implemented: ControlledAdjointS");
        }
        void ControlledAdjointT(long /*numControls*/, QubitIdType* /*controls*/, QubitIdType /*target*/) override
        {
            throw std::logic_error("not_implemented: ControlledAdjointT");
        }
        Result Measure(long /*numBases*/, PauliId* /*bases*/, long /*numTargets*/, QubitIdType* /*targets*/) override
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

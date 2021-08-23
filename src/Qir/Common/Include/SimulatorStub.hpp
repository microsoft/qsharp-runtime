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
        qubitid_t AllocateQubit() override
        {
            throw std::logic_error("not_implemented: AllocateQubit");
        }
        void ReleaseQubit(qubitid_t /* qubit */) override
        {
            throw std::logic_error("not_implemented: ReleaseQubit");
        }
        virtual std::string QubitToString(qubitid_t /* qubit */) override
        {
            throw std::logic_error("not_implemented: QubitToString");
        }
        void X(qubitid_t /*target*/) override
        {
            throw std::logic_error("not_implemented: X");
        }
        void Y(qubitid_t /*target*/) override
        {
            throw std::logic_error("not_implemented: Y");
        }
        void Z(qubitid_t /* target */) override
        {
            throw std::logic_error("not_implemented: Z");
        }
        void H(qubitid_t /*target*/) override
        {
            throw std::logic_error("not_implemented: H");
        }
        void S(qubitid_t /*target*/) override
        {
            throw std::logic_error("not_implemented: S");
        }
        void T(qubitid_t /*target*/) override
        {
            throw std::logic_error("not_implemented: T");
        }
        void R(PauliId /* axis */, qubitid_t /* target */, double /* theta */) override
        {
            throw std::logic_error("not_implemented: R");
        }
        void Exp(long /* numTargets */, PauliId* /* paulis */, qubitid_t* /* targets */, double /* theta */) override
        {
            throw std::logic_error("not_implemented: Exp");
        }
        void ControlledX(long /*numControls*/, qubitid_t* /*controls*/, qubitid_t /*target*/) override
        {
            throw std::logic_error("not_implemented: ControlledX");
        }
        void ControlledY(long /*numControls*/, qubitid_t* /*controls*/, qubitid_t /*target*/) override
        {
            throw std::logic_error("not_implemented: ControlledY");
        }
        void ControlledZ(long /*numControls*/, qubitid_t* /*controls*/, qubitid_t /*target*/) override
        {
            throw std::logic_error("not_implemented: ControlledZ");
        }
        void ControlledH(long /*numControls*/, qubitid_t* /*controls*/, qubitid_t /*target*/) override
        {
            throw std::logic_error("not_implemented: ControlledH");
        }
        void ControlledS(long /*numControls*/, qubitid_t* /*controls*/, qubitid_t /*target*/) override
        {
            throw std::logic_error("not_implemented: ControlledS");
        }
        void ControlledT(long /*numControls*/, qubitid_t* /*controls*/, qubitid_t /*target*/) override
        {
            throw std::logic_error("not_implemented: ControlledT");
        }
        void ControlledR(long /*numControls*/, qubitid_t* /*controls*/, PauliId /*axis*/, qubitid_t /*target*/,
                         double /*theta*/) override
        {
            throw std::logic_error("not_implemented: ControlledR");
        }
        void ControlledExp(long /*numControls*/, qubitid_t* /*controls*/, long /*numTargets*/, PauliId* /*paulis*/,
                           qubitid_t* /*targets*/, double /*theta*/) override
        {
            throw std::logic_error("not_implemented: ControlledExp");
        }
        void AdjointS(qubitid_t /*target*/) override
        {
            throw std::logic_error("not_implemented: AdjointS");
        }
        void AdjointT(qubitid_t /*target*/) override
        {
            throw std::logic_error("not_implemented: AdjointT");
        }
        void ControlledAdjointS(long /*numControls*/, qubitid_t* /*controls*/, qubitid_t /*target*/) override
        {
            throw std::logic_error("not_implemented: ControlledAdjointS");
        }
        void ControlledAdjointT(long /*numControls*/, qubitid_t* /*controls*/, qubitid_t /*target*/) override
        {
            throw std::logic_error("not_implemented: ControlledAdjointT");
        }
        Result Measure(long /*numBases*/, PauliId* /*bases*/, long /*numTargets*/, qubitid_t* /*targets*/) override
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

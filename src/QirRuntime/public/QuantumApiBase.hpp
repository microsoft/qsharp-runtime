#pragma once

#include <exception>

#include "IQuantumApi.hpp"

namespace quantum
{
    class CQuantumApiBase : public IQuantumApi
    {
      public:
        // Qubit management
        Qubit AllocateQubit() override
        {
            throw std::logic_error("not_implemented");
        }
        void ReleaseQubit(Qubit qubit) override
        {
            throw std::logic_error("not_implemented");
        }
        void GetState(TGetStateCallback callback) override
        {
            throw std::logic_error("not_implemented");
        }
        virtual std::string DumpQubit(Qubit qubit) override
        {
            throw std::logic_error("not_implemented");
        }

        // Shortcuts
        void CX(Qubit control, Qubit target) override
        {
            ControlledX(1, &control, target);
        }
        void CY(Qubit control, Qubit target) override
        {
            ControlledY(1, &control, target);
        }
        void CZ(Qubit control, Qubit target) override
        {
            ControlledZ(1, &control, target);
        }

        // Elementary operatons
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
        void SWAP(Qubit target1, Qubit target2) override
        {
            throw std::logic_error("not_implemented");
        }
        void Clifford(CliffordId cliffordId, PauliId pauli, Qubit target) override
        {
            throw std::logic_error("not_implemented");
        }
        void Unitary(long numTargets, double** unitary, Qubit targets[]) override
        {
            throw std::logic_error("not_implemented");
        }

        void R(PauliId axis, Qubit target, double theta) override
        {
            throw std::logic_error("not_implemented");
        }
        void RFraction(PauliId axis, Qubit target, long numerator, int power) override
        {
            throw std::logic_error("not_implemented");
        }
        void R1(Qubit target, double theta) override
        {
            throw std::logic_error("not_implemented");
        }
        void R1Fraction(Qubit target, long numerator, int power) override
        {
            throw std::logic_error("not_implemented");
        }
        void Exp(long numTargets, PauliId paulis[], Qubit targets[], double theta) override
        {
            throw std::logic_error("not_implemented");
        }
        void ExpFraction(long numTargets, PauliId paulis[], Qubit targets[], long numerator, int power) override
        {
            throw std::logic_error("not_implemented");
        }

        // Multicontrolled operations
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
        void ControlledSWAP(long numControls, Qubit controls[], Qubit target1, Qubit target2) override
        {
            throw std::logic_error("not_implemented");
        }
        void ControlledClifford(long numControls, Qubit controls[], CliffordId cliffordId, PauliId pauli, Qubit target)
            override
        {
            throw std::logic_error("not_implemented");
        }
        void ControlledUnitary(long numControls, Qubit controls[], long numTargets, double** unitary, Qubit targets[])
            override
        {
            throw std::logic_error("not_implemented");
        }

        void ControlledR(long numControls, Qubit controls[], PauliId axis, Qubit target, double theta) override
        {
            throw std::logic_error("not_implemented");
        }
        void ControlledRFraction(
            long numControls,
            Qubit controls[],
            PauliId axis,
            Qubit target,
            long numerator,
            int power) override
        {
            throw std::logic_error("not_implemented");
        }
        void ControlledR1(long numControls, Qubit controls[], Qubit target, double theta) override
        {
            throw std::logic_error("not_implemented");
        }
        void ControlledR1Fraction(long numControls, Qubit controls[], Qubit target, long numerator, int power) override
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
        void ControlledExpFraction(
            long numControls,
            Qubit controls[],
            long numTargets,
            PauliId paulis[],
            Qubit targets[],
            long numerator,
            int power) override
        {
            throw std::logic_error("not_implemented");
        }

        // Adjoint operations
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

        bool Assert(long numTargets, PauliId bases[], Qubit targets[], Result result, const char* failureMessage)
            override
        {
            throw std::logic_error("not_implemented");
        }
        bool AssertProbability(
            long numTargets,
            PauliId bases[],
            Qubit targets[],
            double probabilityOfZero,
            double precision,
            const char* failureMessage) override
        {
            throw std::logic_error("not_implemented");
        }

        // Results
        Result M(Qubit target) override
        {
            throw std::logic_error("not_implemented");
        }
        Result Measure(long numBases, PauliId bases[], long numTargets, Qubit targets[]) override
        {
            throw std::logic_error("not_implemented");
        }
        void Reset(Qubit target) override
        {
            throw std::logic_error("not_implemented");
        }
        void ReleaseResult(Result result) override
        {
            throw std::logic_error("not_implemented");
        }
        TernaryBool AreEqualResults(Result r1, Result r2) override
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

} // namespace quantum
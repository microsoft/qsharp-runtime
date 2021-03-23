// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#include <cassert>
#include <vector>

#include "QirRuntimeApi_I.hpp"
#include "QSharpSimApi_I.hpp"
#include "SimFactory.hpp"

#include "BitStates.hpp"

namespace Microsoft
{
namespace Quantum
{
    /*==============================================================================
        CToffoliSimulator
        Simulator for reversible classical logic.
    ==============================================================================*/
    class CToffoliSimulator final : public IRuntimeDriver, public IQuantumGateSet, public IDiagnostics
    {
        long lastUsedId = -1;

        // State of a qubit is represented by a bit in states indexed by qubit's id,
        // bits 0 and 1 correspond to |0> and |1> states respectively.
        BitStates states;

        // The clients should never attempt to derefenece the Result, so we'll use fake
        // pointers to avoid allocation and deallocation.
        Result zero = reinterpret_cast<Result>(0xface0000);
        Result one = reinterpret_cast<Result>(0xface1000);

        static long GetQubitId(Qubit qubit)
        {
            return static_cast<long>(reinterpret_cast<int64_t>(qubit));
        }

      public:
        CToffoliSimulator() = default;
        ~CToffoliSimulator() = default;

        ///
        /// Implementation of IRuntimeDriver
        ///
        void ReleaseResult(Result result) override {}

        bool AreEqualResults(Result r1, Result r2) override
        {
            return (r1 == r2);
        }

        ResultValue GetResultValue(Result result) override
        {
            return (result == one) ? Result_One : Result_Zero;
        }

        Result UseZero() override
        {
            return zero;
        }
        Result UseOne() override
        {
            return one;
        }

        Qubit AllocateQubit() override
        {
            this->lastUsedId++;
            this->states.ExtendToInclude(this->lastUsedId);
            return reinterpret_cast<Qubit>(this->lastUsedId);
        }

        void ReleaseQubit(Qubit qubit) override
        {
            const long id = GetQubitId(qubit);
            assert(id <= this->lastUsedId);
            assert(!this->states.IsBitSetAt(id));
        }

        std::string QubitToString(Qubit qubit) override
        {
            const long id = GetQubitId(qubit);
            return std::to_string(id) + ":" + (this->states.IsBitSetAt(id) ? "1" : "0");
        }

        ///
        /// Implementation of IDiagnostics
        ///
        bool Assert(long numTargets, PauliId* bases, Qubit* targets, Result result, const char* failureMessage) override
        {
            // Measurements in Toffoli simulator don't change the state.
            // TODO: log failureMessage?
            return AreEqualResults(result, Measure(numTargets, bases, numTargets, targets));
        }

        bool AssertProbability(
            long numTargets,
            PauliId bases[],
            Qubit targets[],
            double probabilityOfZero,
            double precision,
            const char* failureMessage) override
        {
            assert(precision >= 0);

            // Measurements in Toffoli simulator don't change the state, and the result is deterministic.
            const double actualZeroProbability = (Measure(numTargets, bases, numTargets, targets) == zero) ? 1.0 : 0.0;
            return std::abs(actualZeroProbability - probabilityOfZero) < precision;
        }

        void GetState(TGetStateCallback callback, long numQubits = 0, Qubit qubits[] = nullptr) override
        {
            throw std::logic_error("operation_not_supported");
        }


        ///
        /// Implementation of IQuantumGateSet
        ///
        void X(Qubit qubit) override
        {
            this->states.FlipBitAt(GetQubitId(qubit));
        }

        void ControlledX(long numControls, Qubit* const controls, Qubit qubit) override
        {
            bool allControlsSet = true;
            for (long i = 0; i < numControls; i++)
            {
                if (!this->states.IsBitSetAt(GetQubitId(controls[i])))
                {
                    allControlsSet = false;
                    break;
                }
            }

            if (allControlsSet)
            {
                this->states.FlipBitAt(GetQubitId(qubit));
            }
        }


        Result Measure(long numBases, PauliId bases[], long numTargets, Qubit targets[]) override
        {
            bool odd = false;
            for (long i = 0; i < numBases; i++)
            {
                if (bases[i] == PauliId_X || bases[i] == PauliId_Y)
                {
                    throw std::runtime_error("Toffoli simulator only supports measurements in Z basis");
                }
                if (bases[i] == PauliId_Z)
                {
                    odd ^= (this->states.IsBitSetAt(GetQubitId(targets[i])));
                }
            }
            return odd ? one : zero;
        }


        //
        // The rest of the gate set Toffoli simulator doesn't support
        //
        void Y(Qubit target) override
        {
            throw std::logic_error("operation_not_supported");
        }
        void Z(Qubit target) override
        {
            throw std::logic_error("operation_not_supported");
        }
        void H(Qubit target) override
        {
            throw std::logic_error("operation_not_supported");
        }
        void S(Qubit target) override
        {
            throw std::logic_error("operation_not_supported");
        }
        void T(Qubit target) override
        {
            throw std::logic_error("operation_not_supported");
        }
        void R(PauliId axis, Qubit target, double theta) override
        {
            throw std::logic_error("operation_not_supported");
        }
        void Exp(long numTargets, PauliId paulis[], Qubit targets[], double theta) override
        {
            throw std::logic_error("operation_not_supported");
        }
        void ControlledY(long numControls, Qubit controls[], Qubit target) override
        {
            throw std::logic_error("operation_not_supported");
        }
        void ControlledZ(long numControls, Qubit controls[], Qubit target) override
        {
            throw std::logic_error("operation_not_supported");
        }
        void ControlledH(long numControls, Qubit controls[], Qubit target) override
        {
            throw std::logic_error("operation_not_supported");
        }
        void ControlledS(long numControls, Qubit controls[], Qubit target) override
        {
            throw std::logic_error("operation_not_supported");
        }
        void ControlledT(long numControls, Qubit controls[], Qubit target) override
        {
            throw std::logic_error("operation_not_supported");
        }
        void ControlledR(long numControls, Qubit controls[], PauliId axis, Qubit target, double theta) override
        {
            throw std::logic_error("operation_not_supported");
        }
        void ControlledExp(
            long numControls,
            Qubit controls[],
            long numTargets,
            PauliId paulis[],
            Qubit targets[],
            double theta) override
        {
            throw std::logic_error("operation_not_supported");
        }
        void AdjointS(Qubit target) override
        {
            throw std::logic_error("operation_not_supported");
        }
        void AdjointT(Qubit target) override
        {
            throw std::logic_error("operation_not_supported");
        }
        void ControlledAdjointS(long numControls, Qubit controls[], Qubit target) override
        {
            throw std::logic_error("operation_not_supported");
        }
        void ControlledAdjointT(long numControls, Qubit controls[], Qubit target) override
        {
            throw std::logic_error("operation_not_supported");
        }
    };

    std::unique_ptr<IRuntimeDriver> CreateToffoliSimulator()
    {
        return std::make_unique<CToffoliSimulator>();
    }

} // namespace Quantum
} // namespace Microsoft
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#include <cassert>
#include <vector>
#include <iostream>
#include <cstdint>

#include "QirRuntimeApi_I.hpp"
#include "QSharpSimApi_I.hpp"
#include "SimFactory.hpp"

namespace Microsoft
{
namespace Quantum
{
    /*==============================================================================
        CToffoliSimulator
        Simulator for reversible classical logic.
    ==============================================================================*/
    class CToffoliSimulator final
        : public IRuntimeDriver
        , public IQuantumGateSet
        , public IDiagnostics
    {
        QubitIdType nextQubitId = 0;

        // State of a qubit is represented by a bit in states indexed by qubit's id,
        // bits 0 and 1 correspond to |0> and |1> states respectively.
        std::vector<bool> states;

        // The clients should never attempt to derefenece the Result, so we'll use fake
        // pointers to avoid allocation and deallocation.
        Result zero = reinterpret_cast<Result>(0xface0000);
        Result one  = reinterpret_cast<Result>(0xface1000);

      public:
        CToffoliSimulator()           = default;
        ~CToffoliSimulator() override = default;

        ///
        /// Implementation of IRuntimeDriver
        ///
        void ReleaseResult(Result /* result */) override
        {
        }

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

        QubitIdType AllocateQubit() override
        {
            QubitIdType retVal = this->nextQubitId;
            ++(this->nextQubitId);
            assert(this->nextQubitId < std::numeric_limits<QubitIdType>::max()); // Check aginast the risk of overflow.
            this->states.emplace_back(false);
            return retVal;
        }

        void ReleaseQubit([[maybe_unused]] QubitIdType qubit) override
        {
            assert((qubit + 1) == this->nextQubitId);
            assert(!this->states.at(static_cast<size_t>(qubit)));
            --(this->nextQubitId);
            this->states.pop_back();
        }

        std::string QubitToString(QubitIdType qubit) override
        {
            return std::to_string(qubit) + ":" + (this->states.at(static_cast<size_t>(qubit)) ? "1" : "0");
        }

        ///
        /// Implementation of IDiagnostics
        ///
        bool Assert(long numTargets, PauliId* bases, QubitIdType* targets, Result result,
                    const char* /* failureMessage */) override
        {
            // Measurements in Toffoli simulator don't change the state.
            // TODO: log failureMessage?
            return AreEqualResults(result, Measure(numTargets, bases, numTargets, targets));
        }

        bool AssertProbability(long numTargets, PauliId bases[], QubitIdType targets[], double probabilityOfZero,
                               double precision, const char* /* failureMessage */) override
        {
            assert(precision >= 0);

            // Measurements in Toffoli simulator don't change the state, and the result is deterministic.
            const double actualZeroProbability = (Measure(numTargets, bases, numTargets, targets) == zero) ? 1.0 : 0.0;
            return std::abs(actualZeroProbability - probabilityOfZero) < precision;
        }

        // Deprecated, use `DumpMachine()` and `DumpRegister()` instead.
        void GetState(TGetStateCallback /* callback */) override
        {
            throw std::logic_error("operation_not_supported");
        }

        void DumpMachine(const void* /* location */) override
        {
            std::cerr << __func__ << " is not yet implemented" << std::endl; // #645
        }

        void DumpRegister(const void* /* location */, const QirArray* /* qubits */) override
        {
            std::cerr << __func__ << " is not yet implemented" << std::endl; // #645
        }


        ///
        /// Implementation of IQuantumGateSet
        ///
        void X(QubitIdType qubit) override
        {
            this->states.at(static_cast<size_t>(qubit)).flip();
        }

        void ControlledX(long numControls, QubitIdType* const controls, QubitIdType qubit) override
        {
            bool allControlsSet = true;
            for (long i = 0; i < numControls; i++)
            {
                if (!this->states.at(static_cast<size_t>(controls[i])))
                {
                    allControlsSet = false;
                    break;
                }
            }

            if (allControlsSet)
            {
                this->states.at(static_cast<size_t>(qubit)).flip();
            }
        }


        Result Measure(long numBases, PauliId bases[], long /* numTargets */, QubitIdType targets[]) override
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
                    odd ^= (this->states.at(static_cast<size_t>(targets[i])));
                }
            }
            return odd ? one : zero;
        }


        //
        // The rest of the gate set Toffoli simulator doesn't support
        //
        void Y(QubitIdType /*target*/) override
        {
            throw std::logic_error("operation_not_supported");
        }
        void Z(QubitIdType /*target*/) override
        {
            throw std::logic_error("operation_not_supported");
        }
        void H(QubitIdType /*target*/) override
        {
            throw std::logic_error("operation_not_supported");
        }
        void S(QubitIdType /*target*/) override
        {
            throw std::logic_error("operation_not_supported");
        }
        void T(QubitIdType /*target*/) override
        {
            throw std::logic_error("operation_not_supported");
        }
        void R(PauliId /* axis */, QubitIdType /*target*/, double /* theta */) override
        {
            throw std::logic_error("operation_not_supported");
        }
        void Exp(long /* numTargets */, PauliId* /* paulis */, QubitIdType* /*targets*/, double /* theta */) override
        {
            throw std::logic_error("operation_not_supported");
        }
        void ControlledY(long /*numControls*/, QubitIdType* /*controls*/, QubitIdType /*target*/) override
        {
            throw std::logic_error("operation_not_supported");
        }
        void ControlledZ(long /*numControls*/, QubitIdType* /*controls*/, QubitIdType /*target*/) override
        {
            throw std::logic_error("operation_not_supported");
        }
        void ControlledH(long /*numControls*/, QubitIdType* /*controls*/, QubitIdType /*target*/) override
        {
            throw std::logic_error("operation_not_supported");
        }
        void ControlledS(long /*numControls*/, QubitIdType* /*controls*/, QubitIdType /*target*/) override
        {
            throw std::logic_error("operation_not_supported");
        }
        void ControlledT(long /*numControls*/, QubitIdType* /*controls*/, QubitIdType /*target*/) override
        {
            throw std::logic_error("operation_not_supported");
        }
        void ControlledR(long /*numControls*/, QubitIdType* /*controls*/, PauliId /*axis*/, QubitIdType /*target*/,
                         double /*theta*/) override
        {
            throw std::logic_error("operation_not_supported");
        }
        void ControlledExp(long /*numControls*/, QubitIdType* /*controls*/, long /*numTargets*/, PauliId* /*paulis*/,
                           QubitIdType* /*targets*/, double /* theta */) override
        {
            throw std::logic_error("operation_not_supported");
        }
        void AdjointS(QubitIdType /*target*/) override
        {
            throw std::logic_error("operation_not_supported");
        }
        void AdjointT(QubitIdType /*target*/) override
        {
            throw std::logic_error("operation_not_supported");
        }
        void ControlledAdjointS(long /*numControls*/, QubitIdType* /*controls*/, QubitIdType /*target*/) override
        {
            throw std::logic_error("operation_not_supported");
        }
        void ControlledAdjointT(long /*numControls*/, QubitIdType* /*controls*/, QubitIdType /*target*/) override
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

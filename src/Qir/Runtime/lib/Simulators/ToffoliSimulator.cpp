// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#include <cassert>
#include <vector>
#include <iostream>
#include <cstdint>

#include "QirTypes.hpp"
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
        qubitid_t nextQubitId = 0;

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

        qubitid_t AllocateQubit() override
        {
            qubitid_t retVal = this->nextQubitId;
            ++(this->nextQubitId);
            assert(this->nextQubitId < std::numeric_limits<qubitid_t>::max()); // Check aginast the risk of overflow.
            this->states.emplace_back(false);
            return retVal;
        }

        void ReleaseQubit(qubitid_t qubit) override
        {
            assert((qubit + 1) == this->nextQubitId);
            assert(!this->states.at(qubit));
            --(this->nextQubitId);
            this->states.pop_back();
        }

        std::string QubitToString(qubitid_t qubit) override
        {
            return std::to_string(qubit) + ":" + (this->states.at(static_cast<size_t>(qubit)) ? "1" : "0");
        }

        ///
        /// Implementation of IDiagnostics
        ///
        bool Assert(long numTargets, PauliId* bases, qubitid_t* targets, Result result,
                    const char* /* failureMessage */) override
        {
            // Measurements in Toffoli simulator don't change the state.
            // TODO: log failureMessage?
            return AreEqualResults(result, Measure(numTargets, bases, numTargets, targets));
        }

        bool AssertProbability(long numTargets, PauliId bases[], qubitid_t targets[], double probabilityOfZero,
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
        void X(qubitid_t qubit) override
        {
            this->states.at(qubit).flip();
        }

        void ControlledX(long numControls, qubitid_t* const controls, qubitid_t qubit) override
        {
            bool allControlsSet = true;
            for (long i = 0; i < numControls; i++)
            {
                if (!this->states.at(controls[i]))
                {
                    allControlsSet = false;
                    break;
                }
            }

            if (allControlsSet)
            {
                this->states.at(qubit).flip();
            }
        }


        Result Measure(long numBases, PauliId bases[], long /* numTargets */, qubitid_t targets[]) override
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
                    odd ^= (this->states.at(targets[i]));
                }
            }
            return odd ? one : zero;
        }


        //
        // The rest of the gate set Toffoli simulator doesn't support
        //
        void Y(qubitid_t /*target*/) override
        {
            throw std::logic_error("operation_not_supported");
        }
        void Z(qubitid_t /*target*/) override
        {
            throw std::logic_error("operation_not_supported");
        }
        void H(qubitid_t /*target*/) override
        {
            throw std::logic_error("operation_not_supported");
        }
        void S(qubitid_t /*target*/) override
        {
            throw std::logic_error("operation_not_supported");
        }
        void T(qubitid_t /*target*/) override
        {
            throw std::logic_error("operation_not_supported");
        }
        void R(PauliId /* axis */, qubitid_t /*target*/, double /* theta */) override
        {
            throw std::logic_error("operation_not_supported");
        }
        void Exp(long /* numTargets */, PauliId* /* paulis */, qubitid_t* /*targets*/, double /* theta */) override
        {
            throw std::logic_error("operation_not_supported");
        }
        void ControlledY(long /*numControls*/, qubitid_t* /*controls*/, qubitid_t /*target*/) override
        {
            throw std::logic_error("operation_not_supported");
        }
        void ControlledZ(long /*numControls*/, qubitid_t* /*controls*/, qubitid_t /*target*/) override
        {
            throw std::logic_error("operation_not_supported");
        }
        void ControlledH(long /*numControls*/, qubitid_t* /*controls*/, qubitid_t /*target*/) override
        {
            throw std::logic_error("operation_not_supported");
        }
        void ControlledS(long /*numControls*/, qubitid_t* /*controls*/, qubitid_t /*target*/) override
        {
            throw std::logic_error("operation_not_supported");
        }
        void ControlledT(long /*numControls*/, qubitid_t* /*controls*/, qubitid_t /*target*/) override
        {
            throw std::logic_error("operation_not_supported");
        }
        void ControlledR(long /*numControls*/, qubitid_t* /*controls*/, PauliId /*axis*/, qubitid_t /*target*/,
                         double /*theta*/) override
        {
            throw std::logic_error("operation_not_supported");
        }
        void ControlledExp(long /*numControls*/, qubitid_t* /*controls*/, long /*numTargets*/, PauliId* /*paulis*/,
                           qubitid_t* /*targets*/, double /* theta */) override
        {
            throw std::logic_error("operation_not_supported");
        }
        void AdjointS(qubitid_t /*target*/) override
        {
            throw std::logic_error("operation_not_supported");
        }
        void AdjointT(qubitid_t /*target*/) override
        {
            throw std::logic_error("operation_not_supported");
        }
        void ControlledAdjointS(long /*numControls*/, qubitid_t* /*controls*/, qubitid_t /*target*/) override
        {
            throw std::logic_error("operation_not_supported");
        }
        void ControlledAdjointT(long /*numControls*/, qubitid_t* /*controls*/, qubitid_t /*target*/) override
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

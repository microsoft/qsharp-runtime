#include <assert.h>
#include <vector>

#include "IQuantumApi.hpp"
#include "SimFactory.hpp"

#include "BitStates.hpp"
#include "QuantumApiBase.hpp"

namespace quantum
{
    /*==============================================================================
        CToffoliSimulator
        Simulator for reversible classical logic.
    ==============================================================================*/
    class CToffoliSimulator final : public CQuantumApiBase
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
            return reinterpret_cast<long>(qubit);
        }

      public:
        CToffoliSimulator() = default;
        ~CToffoliSimulator() = default;

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

        Result M(Qubit qubit) override
        {
            return (this->states.IsBitSetAt(GetQubitId(qubit)) ? one : zero);
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

        void ReleaseResult(Result result) override {}

        TernaryBool AreEqualResults(Result r1, Result r2) override
        {
            return r1 == r2 ? TernaryBool_True : TernaryBool_False;
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
            long id = GetQubitId(qubit);
            assert(id <= this->lastUsedId);
            assert(!this->states.IsBitSetAt(id));
        }

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
    };

    std::unique_ptr<IQuantumApi> CreateToffoliSimulator()
    {
        return std::make_unique<CToffoliSimulator>();
    }

} // namespace quantum
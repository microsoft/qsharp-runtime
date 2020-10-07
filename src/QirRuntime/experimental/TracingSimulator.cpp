#include <algorithm>
#include <assert.h>
#include <iostream>
#include <unordered_set>

#include "ExperimentalSimFactory.hpp"

#include "IIdAllocationPolicy.hpp"
#include "IntervalsColoring.hpp"
#include "QuantumApiBase.hpp"
#include "QubitAllocationPolicies.hpp"
#include "QubitInterferences.hpp"
#include "ResourceStatistics.hpp"

using namespace std;

namespace quantum
{
    class CTracingSimulator;
    struct CResourcesTranslator final : public ITranslator
    {
        ResourceStatistics stats = {0};
        CTracingSimulator* owner = nullptr;

        void PrintRepresentation(ostringstream& os, ostringstream* errors) override;
    };

    struct CTracingQubit
    {
        // `endDepth` is the depth of the last gate this qubited participated in, starting
        // depth of every qubit is zero (which might not be optimal) unless it first participates
        // in a gate with qubits at greater depth.
        long startDepth = 0;
        long endDepth = 0;

        // Records the time (which is also id) of the last operation this qubit participated in. Needed to build
        // the interference graph.
        long lastOperation = 0;

        // To be used by algo::CalculateMinColoringSize algorithm. This algorithm is optimal
        // for our rigid definition of start/end depths. However, it's not optimal in the sense
        // that it doesn't allow delaying a gate execution even if that could reuse a qubit.
        inline long Start() const
        {
            return startDepth;
        }
        inline long End() const
        {
            return endDepth;
        }
    };

    /*==============================================================================
        CTracingSimulator
        The simulator counts allocated qubits and calls to all gates.
    ==============================================================================*/
    class CTracingSimulator final : public CQuantumApiBase
    {
        long time = 0;
        OptimizeFor settings;

        shared_ptr<ITranslator> itranslator = nullptr;
        CResourcesTranslator* resourceTranslator = nullptr;

        unique_ptr<IIdAllocationPolicy> idAllocationPolicy = nullptr;
        vector<CTracingQubit> qubits; // qubit id is the index into this vector

        // For optimizing width of the circuit.
        algo::CQubitInterferences qubitInterferences;

        long GetQubitId(Qubit qubit) const
        {
            return reinterpret_cast<long>(qubit);
        }

        static void UpdateQubit(CTracingQubit& qubit, long depth, long operation)
        {
            qubit.lastOperation = operation;

            if (qubit.startDepth == 0)
            {
                qubit.startDepth = depth;
            }
            qubit.endDepth = depth;
        }

        void UpdateQubitsAndCircuitDepth(Qubit target, long count = 0, Qubit* controls = nullptr)
        {
            this->time++;

            vector<long> previousOps;
            unordered_set<long> participatingQubits;
            participatingQubits.reserve(count + 1);
            // circuit depth is defined by the deepest of the participating qubits
            long maxDepth = -1;
            for (int i = 0; i < count; i++)
            {
                long id = GetQubitId(controls[i]);
                assert(id < this->qubits.size());
                maxDepth = std::max(maxDepth, this->qubits[id].endDepth);

                participatingQubits.insert(id);
                if (this->qubits[id].lastOperation > 0)
                {
                    previousOps.push_back(this->qubits[id].lastOperation);
                }
            }

            long targetId = GetQubitId(target);
            assert(targetId < this->qubits.size());
            participatingQubits.insert(targetId);
            maxDepth = std::max(maxDepth, this->qubits[targetId].endDepth);
            this->resourceTranslator->stats.cCircuitDepth =
                std::max(++maxDepth, this->resourceTranslator->stats.cCircuitDepth);

            if (this->qubits[targetId].lastOperation > 0)
            {
                previousOps.push_back(this->qubits[targetId].lastOperation);
            }

            // add the operation to the interference graph
            const long operationId = this->time;
            this->qubitInterferences.AddOperation(operationId, previousOps, participatingQubits);

            // record the operation on the participating qubits
            for (int i = 0; i < count; i++)
            {
                UpdateQubit(this->qubits[GetQubitId(controls[i])], maxDepth, operationId);
            }
            UpdateQubit(this->qubits[GetQubitId(target)], maxDepth, operationId);
        }

      public:
        explicit CTracingSimulator(shared_ptr<ITranslator> iTranslator, OptimizeFor settings)
            : settings(settings)
            , itranslator(std::move(iTranslator))
        {
            resourceTranslator = (static_cast<CResourcesTranslator*>(itranslator.get()));
            resourceTranslator->owner = this;
            this->idAllocationPolicy = make_unique<CNoQubitReuseAllocationPolicy>();
        }

        ~CTracingSimulator() = default;

        void FinalizeStatistics()
        {
            if (this->settings == OptimizeFor_CircuitDepth && !this->qubits.empty())
            {
                const long cirquitDepth = this->resourceTranslator->stats.cCircuitDepth;
                bool found = false;
                for (CTracingQubit& q : this->qubits)
                {
                    found = (found || q.endDepth == cirquitDepth);
                    assert(q.endDepth < cirquitDepth + 1);
                }
                assert(found);

                // Could any of the qubits be reused to decrease the width of the circuit?
                this->resourceTranslator->stats.cQubitWidth = algo::CalculateMinColoringSize(this->qubits);
            }

            if (this->settings == OptimizeFor_QubitWidth)
            {
                this->resourceTranslator->stats.cQubitWidth = this->qubitInterferences.EstimateCirquitWidth();
                // TODO: figure out the best depth...
                this->resourceTranslator->stats.cCircuitDepth = -1;
            }
        }

        void X(Qubit qubit) override
        {
            UpdateQubitsAndCircuitDepth(qubit);
            this->resourceTranslator->stats.cX++;
        }
        void ControlledX(long cControls, Qubit* controls, Qubit target) override
        {
            UpdateQubitsAndCircuitDepth(target, cControls, controls);
            this->resourceTranslator->stats.cCX++;
        }
        void Y(Qubit qubit) override
        {
            UpdateQubitsAndCircuitDepth(qubit);
            this->resourceTranslator->stats.cY++;
        }
        void ControlledY(long cControls, Qubit* controls, Qubit target) override
        {
            UpdateQubitsAndCircuitDepth(target, cControls, controls);
            this->resourceTranslator->stats.cCY++;
        }
        void Z(Qubit qubit) override
        {
            UpdateQubitsAndCircuitDepth(qubit);
            this->resourceTranslator->stats.cZ++;
        }
        void ControlledZ(long cControls, Qubit* controls, Qubit target) override
        {
            UpdateQubitsAndCircuitDepth(target, cControls, controls);
            this->resourceTranslator->stats.cCZ++;
        }
        void H(Qubit qubit) override
        {
            UpdateQubitsAndCircuitDepth(qubit);
            this->resourceTranslator->stats.cH++;
        }
        void ControlledH(long cControls, Qubit* controls, Qubit target) override
        {
            UpdateQubitsAndCircuitDepth(target, cControls, controls);
            this->resourceTranslator->stats.cCH++;
        }
        void S(Qubit qubit) override
        {
            UpdateQubitsAndCircuitDepth(qubit);
            this->resourceTranslator->stats.cS++;
        }
        void ControlledS(long cControls, Qubit* controls, Qubit target) override
        {
            UpdateQubitsAndCircuitDepth(target, cControls, controls);
            this->resourceTranslator->stats.cCS++;
        }
        void SAdjoint(Qubit qubit) override
        {
            UpdateQubitsAndCircuitDepth(qubit);
            this->resourceTranslator->stats.cAS++;
        }
        void ControlledSAdjoint(long cControls, Qubit* controls, Qubit target) override
        {
            UpdateQubitsAndCircuitDepth(target, cControls, controls);
            this->resourceTranslator->stats.cCAS++;
        }
        void T(Qubit qubit) override
        {
            UpdateQubitsAndCircuitDepth(qubit);
            this->resourceTranslator->stats.cT++;
        }
        void ControlledT(long cControls, Qubit* controls, Qubit target) override
        {
            UpdateQubitsAndCircuitDepth(target, cControls, controls);
            this->resourceTranslator->stats.cCT++;
        }
        void TAdjoint(Qubit qubit) override
        {
            UpdateQubitsAndCircuitDepth(qubit);
            this->resourceTranslator->stats.cAT++;
        }
        void ControlledTAdjoint(long cControls, Qubit* controls, Qubit target) override
        {
            UpdateQubitsAndCircuitDepth(target, cControls, controls);
            this->resourceTranslator->stats.cCAT++;
        }
        void R(PauliId, Qubit qubit, double) override
        {
            UpdateQubitsAndCircuitDepth(qubit);
            this->resourceTranslator->stats.cR++;
        }
        void ControlledR(long cControls, Qubit* controls, PauliId, Qubit target, double) override
        {
            UpdateQubitsAndCircuitDepth(target, cControls, controls);
            this->resourceTranslator->stats.cCR++;
        }

        //==========================================================================
        // Currently the tracer doesn't handle conditions on measurements and simply
        // assumes that all measurements deterministically yield "Zero".
        Result zero = reinterpret_cast<Result>(0xface0000);
        Result one = reinterpret_cast<Result>(0xface1000);

        Result M(Qubit qubit) override
        {
            UpdateQubitsAndCircuitDepth(qubit);
            this->resourceTranslator->stats.cM++;
            return zero;
        }

        Result Measure(long, PauliId* const, long cQubits, Qubit* const qubits) override
        {
            assert(cQubits > 0);
            if (cQubits == 1)
            {
                UpdateQubitsAndCircuitDepth(qubits[0]);
            }
            else
            {
                UpdateQubitsAndCircuitDepth(qubits[0], cQubits - 1, &qubits[1]);
            }
            this->resourceTranslator->stats.cM++;
            return zero;
        }

        void ReleaseResult(Result) override {}

        TernaryBool AreEqualResults(Result r1, Result r2) override
        {
            return (r1 == r2) ? TernaryBool_True : TernaryBool_False;
        }

        ResultValue GetResultValue(Result r) override
        {
            if (r == one)
            {
                return Result_One;
            }
            return Result_Zero;
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
            long id = this->idAllocationPolicy->AcquireId();
            assert(id < this->qubits.size() + 1);
            if (id == this->qubits.size())
            {
                this->qubits.push_back(CTracingQubit{});
            }

            switch (this->settings)
            {
            case OptimizeFor_CircuitDepth:
                // for now use the most concervative estimate of all qubits allocated upfront
                this->resourceTranslator->stats.cQubitWidth = this->qubits.size();
                break;
            case OptimizeFor_QubitWidth:
                this->resourceTranslator->stats.cQubits++;
                this->resourceTranslator->stats.cQubitWidth =
                    std::max(this->resourceTranslator->stats.cQubitWidth, this->resourceTranslator->stats.cQubits);
                break;
            }

            return reinterpret_cast<Qubit>(id);
        }

        void ReleaseQubit(Qubit qubit) override
        {
            long id = reinterpret_cast<long>(qubit);
            this->idAllocationPolicy->ReleaseId(id);
            this->resourceTranslator->stats.cQubits--;
        }
    };

    void CResourcesTranslator::PrintRepresentation(ostringstream& os, ostringstream* errors)
    {
        // Most of the stats are collected as we go and don't need any additional
        // processing. However, some, such as consistently optimized depth and width
        // of the circuit might need an additional pass.
        owner->FinalizeStatistics();
        stats.Print(os);
    }

    std::shared_ptr<ITranslator> CreateResourcesTranslator()
    {
        return std::make_shared<CResourcesTranslator>();
    }
    std::unique_ptr<IQuantumApi> CreateTracingSimulator(std::shared_ptr<ITranslator> translator, OptimizeFor settings)
    {
        return std::make_unique<CTracingSimulator>(std::move(translator), settings);
    }
} // namespace quantum
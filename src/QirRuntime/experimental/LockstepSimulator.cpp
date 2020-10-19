#include <assert.h>
#include <memory>
#include <vector>

#include "ExperimentalSimFactory.hpp"

#include "IQuantumApi.hpp"
#include "QubitAllocationPolicies.hpp"

using namespace std;

namespace Microsoft
{
namespace Quantum
{
    /*==============================================================================
        CLockstepSimulator
        The simulator allows to drive multiple other simulators in lockstep,
        executing one quantum instruction at a time on all of them.
    ==============================================================================*/
    class CLockstepSimulator : public IQuantumApi
    {
        // The simulators to be executed in lockstep. The caller is responsible for
        // creation and release of these simulators.
        vector<IQuantumApi*> simulators;

        // The manager issues ids for the qubit groups.
        unique_ptr<CReuseLastReleasedQubitAllocationPolicy> qubitIdManager;

        // The qubits, allocated by each simulator have nothing to do with each other,
        // so this simulator matches them by group id, associated with each allocation
        // (or borrowing) of a qubit.
        // FIRST INDEX:    id of a qubit group
        // SECOND INDEX:   qubits allocated by the same simulator
        vector<vector<Qubit>> allocatedQubits;

        // The results, measured by each simulator have nothing to do with each other
        // and can differ in value even if the sequence of quantum operations is identical.
        // We'll store all results, grouped similar to the qubits but we'll use a simpler
        // id management for these.
        // FIRST INDEX:    id of a result group
        // SECOND INDEX:   results from the same simulator
        // The first two items are zero and one
        vector<vector<Result>> trackedResults;

        // If result values are requested, they will be stored into the provided buffer.
        // This simulator doesn't own the buffer!
        ResultValue* resultValues = nullptr;

        /*==========================================================================
            private methods
        ==========================================================================*/
        long GetQubitId(Qubit qubit) const
        {
            long id = static_cast<long>(reinterpret_cast<int64_t>(qubit));

            assert(id >= 0);
            assert(id < this->allocatedQubits.size());
            assert(!this->allocatedQubits[id].empty());
            assert(this->allocatedQubits[id].size() == this->simulators.size());

            return id;
        }

        vector<long> GetQubitIds(long num, Qubit* qubits)
        {
            vector<long> ids{};
            ids.reserve(num);
            for (long i = 0; i < num; i++)
            {
                ids.push_back(GetQubitId(qubits[i]));
            }
            return ids;
        }

        long GetResultId(Result result) const
        {
            long id = static_cast<long>(reinterpret_cast<int64_t>(result));

            assert(id >= 0);
            assert(id < this->trackedResults.size());
            assert(!this->trackedResults[id].empty());
            assert(this->trackedResults[id].size() == this->simulators.size());

            return id;
        }

        void DelegateElementaryOperation(Qubit target, void (IQuantumApi::*op)(Qubit))
        {
            const long id = GetQubitId(target);
            for (size_t simIndex = 0; simIndex < this->allocatedQubits[id].size(); simIndex++)
            {
                (this->simulators[simIndex]->*op)(this->allocatedQubits[id][simIndex]);
            }
        }

        void DelegateElementaryControlledOperation(
            long numControls,
            Qubit controls[],
            Qubit target,
            void (IQuantumApi::*op)(long, Qubit*, Qubit))
        {
            const long targetId = GetQubitId(target);
            vector<long> controlIds = GetQubitIds(numControls, controls);

            vector<Qubit> individualControls(numControls, nullptr);
            for (long simIndex = 0; simIndex < this->simulators.size(); simIndex++)
            {
                for (long i = 0; i < numControls; i++)
                {
                    individualControls[i] = this->allocatedQubits[controlIds[i]][simIndex];
                }
                (this->simulators[simIndex]->*op)(
                    numControls, individualControls.data(), this->allocatedQubits[targetId][simIndex]);
            }
        }

        /*==========================================================================
            public methods
        ==========================================================================*/
      public:
        CLockstepSimulator(vector<IQuantumApi*>&& simulatorsToRunInLockstep, ResultValue* resultsValuesBuffer)
            : simulators(std::move(simulatorsToRunInLockstep))
            , qubitIdManager(make_unique<CReuseLastReleasedQubitAllocationPolicy>())
            , resultValues(resultsValuesBuffer)
        {
            // reserve Zero and One results
            trackedResults.push_back(vector<Result>(simulators.size(), nullptr));
            trackedResults.push_back(vector<Result>(simulators.size(), nullptr));
        }
        ~CLockstepSimulator() = default;

        /*==========================================================================
            Implementation of IQuantumApi
        ==========================================================================*/
        Qubit AllocateQubit() override
        {
            const long id = this->qubitIdManager->AcquireId();
            const long numSimulators = this->simulators.size();

            if (id >= this->allocatedQubits.size())
            {
                this->allocatedQubits.reserve(id + 1);
                const long qubitGroupsToAdd = id + 1 - static_cast<long>(this->allocatedQubits.size());
                for (long i = 0; i < qubitGroupsToAdd; i++)
                {
                    this->allocatedQubits.push_back(vector<Qubit>{});
                    this->allocatedQubits.back().reserve(numSimulators);
                }
            }
            assert(this->allocatedQubits[id].empty());

            for (size_t simIndex = 0; simIndex < numSimulators; simIndex++)
            {
                Qubit q = this->simulators[simIndex]->AllocateQubit();
                this->allocatedQubits[id].push_back(q);
            }

            return reinterpret_cast<Qubit>(id);
        }

        void ReleaseQubit(Qubit qubit) override
        {
            const long id = GetQubitId(qubit);
            for (size_t i = 0; i < this->allocatedQubits[id].size(); i++)
            {
                this->simulators[i]->ReleaseQubit(this->allocatedQubits[id][i]);
            }
            this->allocatedQubits[id].clear();

            // TODO: is it worth shrinking the qubits array if many tail qubit groups
            // have been released?
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
            DelegateElementaryOperation(target, &IQuantumApi::X);
        }
        void Y(Qubit target) override
        {
            DelegateElementaryOperation(target, &IQuantumApi::Y);
        }
        void Z(Qubit target) override
        {
            DelegateElementaryOperation(target, &IQuantumApi::Z);
        }
        void H(Qubit target) override
        {
            DelegateElementaryOperation(target, &IQuantumApi::H);
        }
        void S(Qubit target) override
        {
            DelegateElementaryOperation(target, &IQuantumApi::S);
        }
        void T(Qubit target) override
        {
            DelegateElementaryOperation(target, &IQuantumApi::T);
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
            DelegateElementaryControlledOperation(numControls, controls, target, &IQuantumApi::ControlledX);
        }
        void ControlledY(long numControls, Qubit controls[], Qubit target) override
        {
            DelegateElementaryControlledOperation(numControls, controls, target, &IQuantumApi::ControlledY);
        }
        void ControlledZ(long numControls, Qubit controls[], Qubit target) override
        {
            DelegateElementaryControlledOperation(numControls, controls, target, &IQuantumApi::ControlledZ);
        }
        void ControlledH(long numControls, Qubit controls[], Qubit target) override
        {
            DelegateElementaryControlledOperation(numControls, controls, target, &IQuantumApi::ControlledH);
        }
        void ControlledS(long numControls, Qubit controls[], Qubit target) override
        {
            DelegateElementaryControlledOperation(numControls, controls, target, &IQuantumApi::ControlledS);
        }
        void ControlledT(long numControls, Qubit controls[], Qubit target) override
        {
            DelegateElementaryControlledOperation(numControls, controls, target, &IQuantumApi::ControlledT);
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
            DelegateElementaryOperation(target, &IQuantumApi::SAdjoint);
        }
        void TAdjoint(Qubit target) override
        {
            DelegateElementaryOperation(target, &IQuantumApi::TAdjoint);
        }
        void ControlledSAdjoint(long numControls, Qubit controls[], Qubit target) override
        {
            DelegateElementaryControlledOperation(numControls, controls, target, &IQuantumApi::ControlledSAdjoint);
        }
        void ControlledTAdjoint(long numControls, Qubit controls[], Qubit target) override
        {
            DelegateElementaryControlledOperation(numControls, controls, target, &IQuantumApi::ControlledTAdjoint);
        }

        bool Assert(long numTargets, PauliId bases[], Qubit targets[], Result result, const char* failureMessage)
            override
        {
            vector<long> targetIds = GetQubitIds(numTargets, targets);
            bool assertResult = true;

            vector<Qubit> individualTargets(numTargets, nullptr);
            for (long simIndex = 0; simIndex < this->simulators.size(); simIndex++)
            {
                for (long i = 0; i < numTargets; i++)
                {
                    individualTargets[i] = this->allocatedQubits[targetIds[i]][simIndex];
                }
                if (!this->simulators[simIndex]->Assert(numTargets, bases, individualTargets.data(), result, ""))
                {
                    // TODO: log or report which of the simulators failed, using the failureMessage
                    assertResult = false;
                }
            }
            return assertResult;
        }

        bool AssertProbability(
            long numTargets,
            PauliId bases[],
            Qubit targets[],
            double probabilityOfZero,
            double precision,
            const char* failureMessage) override
        {
            vector<long> targetIds = GetQubitIds(numTargets, targets);
            bool assertResult = true;

            vector<Qubit> individualTargets(numTargets, nullptr);
            for (long simIndex = 0; simIndex < this->simulators.size(); simIndex++)
            {
                for (long i = 0; i < numTargets; i++)
                {
                    individualTargets[i] = this->allocatedQubits[targetIds[i]][simIndex];
                }
                if (!this->simulators[simIndex]->AssertProbability(
                        numTargets, bases, individualTargets.data(), probabilityOfZero, precision, ""))
                {
                    // TODO: log or report which of the simulators failed, using the failureMessage
                    assertResult = false;
                }
            }
            return assertResult;
        }

        // Results
        Result M(Qubit target) override
        {
            const long numSimulators = this->simulators.size();
            const long id = GetQubitId(target);

            vector<Result> results(numSimulators, nullptr);
            for (size_t simIndex = 0; simIndex < numSimulators; simIndex++)
            {
                results[simIndex] = this->simulators[simIndex]->M(this->allocatedQubits[id][simIndex]);
            }
            trackedResults.push_back(results);

            return reinterpret_cast<Result>(trackedResults.size() - 1);
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
            const long id = GetResultId(result);
            for (size_t simIndex = 0; simIndex < this->simulators.size(); simIndex++)
            {
                this->simulators[simIndex]->ReleaseResult(this->trackedResults[id][simIndex]);
            }
            this->trackedResults[id].clear();
        }

        // Results are compared by each simulator (but not across simulators!).
        //   If any of the comparisons is underfined, the cumulative result is undefined.
        //   If all comparisons are defined and any is false the cumulative result is false.
        TernaryBool AreEqualResults(Result r1, Result r2) override
        {
            const long id1 = GetResultId(r1);
            const long id2 = GetResultId(r2);
            TernaryBool acumulatedComparisonResult = TernaryBool_True;
            for (size_t simIndex = 0; simIndex < this->simulators.size(); simIndex++)
            {
                TernaryBool t = this->simulators[simIndex]->AreEqualResults(
                    this->trackedResults[id1][simIndex], this->trackedResults[id2][simIndex]);
                if (t == TernaryBool_Undefined)
                {
                    acumulatedComparisonResult = TernaryBool_Undefined;
                    break;
                }
                else if (t == TernaryBool_False)
                {
                    acumulatedComparisonResult = TernaryBool_False;
                }
            }
            return acumulatedComparisonResult;
        }

        // Due to non-deterministic nature of quantum measurements, the results accross multiple
        // simulators might not agree. The cumulative value could return ResultValue_Undefined
        // in this case but that might be confused with the pending results so for now we'll
        // return the result from the last target.
        // TODO: review and decide how inconsistent results should be handled.
        ResultValue GetResultValue(Result result) override
        {
            const long id = GetResultId(result);
            ResultValue retValue = Result_One;
            for (size_t simIndex = 0; simIndex < this->simulators.size(); simIndex++)
            {
                ResultValue r = this->simulators[simIndex]->GetResultValue(this->trackedResults[id][simIndex]);
                resultValues[simIndex] = r;

                if (r == Result_Pending || retValue != Result_Pending)
                {
                    retValue = r;
                }
            }
            return retValue;
        }
        Result UseZero() override
        {
            if (trackedResults[0][0] == nullptr)
            {
                for (size_t i = 0; i < simulators.size(); i++)
                {
                    trackedResults[0][i] = simulators[i]->UseZero();
                }
            }
            return reinterpret_cast<Result>(0);
        }
        Result UseOne() override
        {
            if (trackedResults[1][0] == nullptr)
            {
                for (size_t i = 0; i < simulators.size(); i++)
                {
                    trackedResults[1][i] = simulators[i]->UseOne();
                }
            }
            return reinterpret_cast<Result>(1);
        }

        // TODO: ClassicalConditions
        // TODO: Notifications
        // TODO: UnitaryAdjoint?
    };

    std::unique_ptr<IQuantumApi> CreateLockstepSimulator(
        vector<IQuantumApi*>&& simulatorsToRunInLockstep,
        ResultValue* resultValueBuffer)
    {
        return make_unique<CLockstepSimulator>(std::move(simulatorsToRunInLockstep), resultValueBuffer);
    }
} // namespace Quantum
} // namespace Microsoft
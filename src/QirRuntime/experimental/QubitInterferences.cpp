#include <algorithm>
#include <assert.h>
#include <unordered_map>
#include <unordered_set>
#include <vector>

#include "QubitInterferences.hpp"

using namespace std;

namespace algo
{

    void CQubitInterferences::AddOperation(
        long timeOfThisOperation,
        const vector<long>& operationsThisOperationDirectlyDependsOn,
        const unordered_set<long>& qubitsInThisOperation)
    {
        assert(operations.count(timeOfThisOperation) == 0);

        this->maxQubitsInSingleOperation =
            std::max<long>(this->maxQubitsInSingleOperation, qubitsInThisOperation.size());

        unordered_map<long /*qubit id*/, unordered_set<long> /*dependent qubits*/>& thisOperationDependencies =
            operations[timeOfThisOperation]; // creates new map

        // Qubits in this operation depend on each other.
        for (long qubitId : qubitsInThisOperation)
        {
            thisOperationDependencies[qubitId].insert(qubitsInThisOperation.begin(), qubitsInThisOperation.end());
        }

        // Propagate transitive qubit dependencies from the earlier operations (union those for the same qubit).
        for (long earlierOp : operationsThisOperationDirectlyDependsOn)
        {
            for (const auto& qubitDependencies : operations[earlierOp])
            {
                const long earlierQubit = qubitDependencies.first;
                const unordered_set<long>& qubitsThatDependOnTheEarlierQubit = qubitDependencies.second;

                thisOperationDependencies[earlierQubit].insert(
                    qubitsThatDependOnTheEarlierQubit.begin(), qubitsThatDependOnTheEarlierQubit.end());
            }
        }

        // Add the qubits from the operation into each dependency set.
        for (auto& qubitDependency : thisOperationDependencies)
        {
            const long qubitId = qubitDependency.first;
            unordered_set<long>& dependentQubits = qubitDependency.second;

            if (qubitsInThisOperation.count(qubitId) == 0)
            {
                dependentQubits.insert(qubitsInThisOperation.begin(), qubitsInThisOperation.end());
            }
        }

        // For the qubits that come with this operation, record the interferences.
        // A _linear interference_ exists between qubit q1 that is being added and the ones in the dependency lists
        // for q1 on this operation. Basically, there is a path through the operations dependency graph that starts
        // and ends with operations that involves q1 -- all qubits used by other operations on the path interfere
        // with q1. For _group interference_ we need to union linear interferences of individual qubits together.
        unordered_set<long> interferingQubits;
        for (long qubitId : qubitsInThisOperation)
        {
            auto dependentQubitsIterator = thisOperationDependencies.find(qubitId);
            if (dependentQubitsIterator != thisOperationDependencies.end())
            {
                const unordered_set<long>& dependentQubits = dependentQubitsIterator->second;
                interferingQubits.insert(dependentQubits.begin(), dependentQubits.end());
            }
        }
        for (long qubitId : qubitsInThisOperation)
        {
            auto dependentQubitsIterator = thisOperationDependencies.find(qubitId);
            if (dependentQubitsIterator != thisOperationDependencies.end())
            {
                for (long interferingQubitId : interferingQubits)
                {
                    if (qubitId != interferingQubitId)
                    {
                        interferences[qubitId].insert(interferingQubitId);
                        interferences[interferingQubitId].insert(qubitId);
                    }
                }
            }
        }
    }

    // The algorithm greedily removes vertices of degree less than registersCount because those can always be
    // colored. If by doing this the interferences graph reduces to an empty set, we know that it can be colored.
    // Otherwise we assume that the give registersCount isn't sufficient (which might not be true, because the order
    // in which we "color" the vertices isn't guaranteed to be optimal).
    static bool CanFit(long registersCount, unordered_map<long, unordered_set<long>>& interferences)
    {
        auto graphIterator = interferences.begin();
        while (graphIterator != interferences.end())
        {
            const long node = graphIterator->first;
            const unordered_set<long>& adjacentNodes = graphIterator->second;

            if (adjacentNodes.size() < registersCount)
            {
                for (long adjacentNode : adjacentNodes)
                {
                    interferences[adjacentNode].erase(node);
                }
                interferences.erase(graphIterator);
                graphIterator = interferences.begin();
            }
            else
            {
                ++graphIterator;
            }
        }

        return interferences.empty();
    }

    // Use the classical graph coloring algorithm to estimate whether the given number of registers is sufficient.
    // Note that qubits cannot spill or split, so we only attempt to color the interference graph into the given
    // number of colors.
    bool CQubitInterferences::CanFit(long registersCount) const
    {
        long maxDegree = 0;
        for (const auto& node : this->interferences)
        {
            const unordered_set<long>& adjacentNodes = node.second;
            maxDegree = std::max<long>(maxDegree, adjacentNodes.size());
        }
        if (maxDegree < registersCount)
        {
            return true;
        }

        unordered_map<long, unordered_set<long>> copy = this->interferences;
        return algo::CanFit(registersCount, copy);
    }

    // Binary search between maxQubitsInSingleOperation and maxDegree+1 of the interference graph
    long CQubitInterferences::EstimateCirquitWidth() const
    {
        long maxDegree = 0;
        for (const auto& node : this->interferences)
        {
            const unordered_set<long>& adjacentNodes = node.second;
            maxDegree = std::max<long>(maxDegree, adjacentNodes.size());
        }

        long requiredNumber = this->maxQubitsInSingleOperation; // required number of colors
        long sufficientNumber = maxDegree + 1;                  // sufficient number of colors
        assert(requiredNumber > 0);
        assert(requiredNumber <= sufficientNumber);

        if (requiredNumber == sufficientNumber)
        {
            return requiredNumber;
        }

        while (requiredNumber < sufficientNumber - 1)
        {
            long candidate = (requiredNumber + sufficientNumber) / 2;
            assert(requiredNumber < candidate);
            assert(candidate < sufficientNumber);

            if (CanFit(candidate))
            {
                sufficientNumber = candidate;
            }
            else
            {
                requiredNumber = candidate;
            }
        }
        assert(requiredNumber == sufficientNumber - 1);
        return CanFit(requiredNumber) ? requiredNumber : sufficientNumber;
    }
} // namespace algo
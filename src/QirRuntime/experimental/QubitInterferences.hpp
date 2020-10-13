#pragma once

#include <unordered_map>
#include <unordered_set>
#include <vector>

using namespace std;

// The optimization is formulated in terms of qubits and operations on them, but it doesn't depend on any of the core
// quantum types so we've placed it into 'algo' namespace.
namespace algo
{
    /*------------------------------------------------------------------------------------------------------------------
    The sequential execution of the quantum program by the simulator imposes a strict full order on the operations.
    We'll refer to this ordering as "time" and assume that each operation takes a single unit of time.

    To begin with we assume that all qubit are pre-allocated and there is no reuse of them. The tracer will attempt
    to find a [close to] optimal strategy for re-use.

    Qubit q2 is said to _depend_ on qubit q1 at time T if there is an operation at time T that involves both
    qubits. From here the dependency relationship is extended by transitivity backward in time. That is, if there is
    a CNOT(q1, q2) sequentially followed by a CNOT(q2, q3), we'll have:
       q1 depends on q2 (from the first CNOT),
       q2 depends on q1 (from the first CNOT),
       q2 depends on q3 (from the second CNOT),
       q3 depends on q2 (from the second CNOT),
       q3 depends on q1 (by transitivity via q2),
    but q1 does *not* depend on q3 (transitivity is applied only backwards).

    Two qubits q1 and q2 are said to _linearly interfere_ at time T if there exists time T' such that:
       1) T <= T'
       2) q2 depends on q1 at T
       3) q1 depends on q2 at T'
    For the example above with two CNOTs, q3 depends on q1 but doesn't interfere with it. As a result the
    circuit can be reduced to two qubits by reusing q1 instead of allocating q3.

    Unfortunately, this definition of interference isn't sufficient. Applied to the circuit like:
        CNOT(q1, q2)
        CNOT(q3, q4)
        CNOT(q2, q3)
    It will identify interferences as: q1 ~ q2, q2 ~ q3, q3 ~ q4 (which can be colored with exactly two colors), 
    but this curcuit cannot be compacted to use only two logical qubits.

    To handle this case we'll extend the notion of linear interference to union interferences of all qubits that
    participate in the same operation. Two qubits q1 and q2 are said to _interfere_ at time T, if there exists qubit q
    such that operation at time T acts on q1 and q, and q linearly interferes with q2 at time T (q might be equal q1, in
    which case q1 and q2 linearly interfere at time T).

    As the simulator is executing the program we'll collect interference data and will later feed it into a registry
    allocation algorithm which would allow to reduce qubit width of the circuit.
    ------------------------------------------------------------------------------------------------------------------*/
    class CQubitInterferences
    {
        // An operation op2 is said to _depend_ on an earlier operation op1, if there exist two qubits q2 and q1 such
        // that:
        //     1) op2 acts on q2,
        //     2) op1 acts on q1,
        //     3) q2 is dependent on q1 at the time of op2.
        //     (or, if both operations act on the same qubit q)
        //
        // An operation op2 is said to _directly depend_ on an earlier operation op1, if there exists qubit q both
        // operations act on and there is no op' that acts on q after op1 but before op2.
        //
        // An operation op is said to _depend_ on qubit q, if there exists an earlier operation op' such that:
        //     1) op' acts on q,
        //     2) op depends on op'.
        // For each operation, uniquely identified by its time, we store a table of all qubits this operation depends
        // on, and for each of these qubits, the union of the qubits that participated along some path of the operations
        // dependency DAG between the operation that first acted on this qubit and this operation.
        //
        // For example, for the sequence of operations and the qubits participating in them:
        //  op1(1) op2(1,2) op3(3) op4(3,4) op5(2,4,5)
        // We'll build the table like this:
        //  op1: 1{1}
        //  op2: 1{1,2}, 2{1,2} (op2 depends on op1 but op1 doesn't add anything to the qubit dependencies)
        //  op3: 3{3}
        //  op4: 3{3,4}, 4{3,4} (op2 depends on op3 but op3 doesn't add anything to the qubit dependencies)
        //  op5: 2{1,2,4,5}, 4{2,3,4,5}, 5{5} (op5 depends on op2 and op4 -- the qubit dependencies are unioned)
        unordered_map<
            long /*id of the operation*/,
            unordered_map<long /*qubit id*/, unordered_set<long> /*dependant qubits*/>>
            operations;

        // Incidence graph of the interfering qubits.
        unordered_map<long /*qubit id*/, unordered_set<long> /*interferes with*/> interferences;

        // To provide the lower boundary for register size estimation search.
        long maxQubitsInSingleOperation = 0;

      public:
        const unordered_map<
            long /*id of the operation*/,
            unordered_map<long /*qubit id*/, unordered_set<long> /*dependant qubits*/>>&
        UseOperations() const
        {
            return operations;
        }
        const unordered_map<long /*qubit id*/, unordered_set<long> /*interferes with*/>& UseInterferences() const
        {
            return interferences;
        }

        // The caller is responsible for providing consisten data:
        //   1) idOfThisOperation should be unique in each call
        //   2) list of operations this operation depends on should only include previously inserted operations
        //   3) if a qubit was used before, there must be listed the corresponding earlier operation
        void AddOperation(
            long idOfThisOperation,
            const vector<long>& operationsThisOperationDirectlyDependsOn,
            const unordered_set<long>& qubitsInThisOperation);

        // Use the classical graph coloring algorithm to estimate whether the given number of registers is sufficient.
        // Note that qubits cannot spill or split, so we only attempt to color the interference graph into the given
        // number of colors.
        bool CanFit(long registersCount) const;

        // Binary search between maxQubitsInSingleOperation and maxDegree+1 of the interference graph
        long EstimateCircuitWidth() const;
    };

} // namespace algo
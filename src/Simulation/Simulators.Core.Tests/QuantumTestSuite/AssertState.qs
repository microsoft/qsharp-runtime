// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.TestSuite {
    
    open Microsoft.Quantum.Simulation.TestSuite.Math;
    open Microsoft.Quantum.Intrinsic;
    
    
    function PruneObservable (observable : Pauli[], qubits : Qubit[]) : (Pauli[], Qubit[]) {
        
        mutable nonIdCount = 0;
        
        for (i in 0 .. Length(observable) - 1) {
            
            if (observable[i] != PauliI) {
                set nonIdCount = nonIdCount + 1;
            }
        }
        
        mutable paulies = new Pauli[nonIdCount];
        mutable qubitsPr = new Qubit[nonIdCount];
        set nonIdCount = 0;
        
        for (i in 0 .. Length(observable) - 1) {
            
            if (observable[i] != PauliI) {
                set paulies w/= nonIdCount <- observable[i];
                set qubitsPr w/= nonIdCount <- qubits[i];
                set nonIdCount += 1;
            }
        }
        
        return (paulies, qubitsPr);
    }
    
    
    operation AssertStateHelper (observableId : Int[], state : Vector, qubits : Qubit[]) : Unit {
        
        let observable = PauliById(observableId);
        let probabilityOfZero = (1.0 + PauliExpectation(observable, state)) / 2.0;
        
        //TODO: remove when AssertProb is fixed
        let (obsPr, qubitsPr) = PruneObservable(observable, qubits);
        let left = Length(qubitsPr);
        
        if (left > 0) {
            AssertProb(obsPr, qubitsPr, Zero, probabilityOfZero, $"Wrong expectation value of an observable", Accuracy());
        }
    }
    
    
    operation AssertState (state : Vector, qubits : Qubit[]) : Unit {
        
        let checkOperation = AssertStateHelper(_, state, qubits);
        IterateThroughCartesianPower(Length(qubits), NumberOfPaulies(), checkOperation);
    }
    
}



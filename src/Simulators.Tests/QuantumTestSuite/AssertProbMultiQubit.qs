namespace Microsoft.Quantum.Simulation.TestSuite {
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Simulation.TestSuite.Math;
    
    
    operation AssertProbMultiQubitTest () : Unit {
        
        
        for (numberOfQubits in 1 .. 2) {
            AssertProbMultiQubitCheck(numberOfQubits);
        }
    }
    
    
    operation AssertProbMultiQubitCheck (numberOfQubits : Int) : Unit {
        
        Message($"Testing on {numberOfQubits} qubits");
        IterateThroughCartesianPower(numberOfQubits, NumberOfPaulies(), AssertProbMultiQubitCheckPerObservable);
    }
    
    
    operation AssertProbMultiQubitCheckPerObservable (observable : Int[]) : Unit {
        
        let obs = PauliById(observable);
        let checkOperation = AssertProbForStateAndObservable(obs, _);
        
        //this would check only computational basis
        mutable statesToCheck = NumberOfComputationalBasisTestStates();
        
        if (IsStabilizerSimulator()) {
            
            //this would check full basis with |0⟩,|1⟩,|+⟩,|i⟩
            set statesToCheck = NumberOfTestStates();
        }
        
        IterateThroughCartesianPower(Length(observable), statesToCheck, checkOperation);
    }
    
    
    operation AssertProbForStateAndObservable (observable : Pauli[], stateId : Int[]) : Unit {
        
        let l = Length(observable);
        
        if (l != Length(stateId)) {
            fail $"arrays observable and stateId must have the same length";
        }
        
        using (qubits = Qubit[l]) {
            _flipToBasis(stateId, qubits);
            let expectedZeroProbability = 0.5 + 0.5 * ExpectedValueForMultiPauliByStateId(observable, stateId);
            let expectedOneProbability = 1.0 - expectedZeroProbability;
            AssertProb(observable, qubits, Zero, expectedZeroProbability, $"", Accuracy());
            AssertProb(observable, qubits, One, expectedOneProbability, $"", Accuracy());
            Adjoint _flipToBasis(stateId, qubits);
        }
    }
    
}



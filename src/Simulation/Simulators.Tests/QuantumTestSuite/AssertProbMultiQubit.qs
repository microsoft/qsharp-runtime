// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.TestSuite {
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Simulation.TestSuite.Math;
    
    
    internal operation FlipToBasis (basis : Int[], qubits : Qubit[]) : Unit is Adj + Ctl {
        if (Length(qubits) != Length(basis))
        {
            fail "qubits and stateIds must have the same length";
        }
            
        for (i in 0 .. Length(qubits) - 1)
        {
            let id = basis[i];
            let qubit = qubits[i];
                
            if (id < 0 or id > 3) {
                fail $"Invalid basis. Must be between 0 and 3, it was {basis}";
            }
                
            if (id == 0)
            {
                I(qubit);
            }
            elif (id == 1)
            {
                X(qubit);
            }
            elif (id == 2)
            {
                H(qubit);
            }
            else
            {
                H(qubit);
                S(qubit);
            }
        }
    }

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
            FlipToBasis(stateId, qubits);
            let expectedZeroProbability = 0.5 + 0.5 * ExpectedValueForMultiPauliByStateId(observable, stateId);
            let expectedOneProbability = 1.0 - expectedZeroProbability;
            AssertMeasurementProbability(observable, qubits, Zero, expectedZeroProbability, $"", Accuracy());
            AssertMeasurementProbability(observable, qubits, One, expectedOneProbability, $"", Accuracy());
            Adjoint FlipToBasis(stateId, qubits);
        }
    }
    
}


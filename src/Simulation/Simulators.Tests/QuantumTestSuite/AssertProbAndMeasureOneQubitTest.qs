// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.TestSuite {
    
    open Microsoft.Quantum.Intrinsic;
    
    
    operation AssertProbAndMeasureOneQubitTest () : Unit {
        
        let totalQubits = MaxQubitsToAllocateForOneQubitTests();
        
        using (qs = Qubit[totalQubits]) {
            
            for (i in 0 .. totalQubits - 1) {
                let q = qs[i];
                
                if (IsStabilizerSimulator()) {
                    MeasureAndCorrect(PauliX, 0.5, q);
                    MeasureAndCorrect(PauliY, 0.5, q);
                    MeasureAndCorrect(PauliZ, 0.5, q);
                }
            }
        }
    }
    
    
    operation ApplyNonCommutingPauli (pauli : Pauli, qubit : Qubit) : Unit {
        
        
        if (pauli == PauliI) {
            fail $"Every pauli commutes with Identity";
        }
        elif (pauli == PauliX) {
            Z(qubit);
        }
        elif (pauli == PauliY) {
            X(qubit);
        }
        //PauliZ
        else {
            Y(qubit);
        }
    }
    
    
    operation MeasureAndCorrect (observable : Pauli, probability : Double, qubit : Qubit) : Unit {
        
        AssertProb([observable], [qubit], Zero, probability, $"", 1E-10);
        let res = Measure([observable], [qubit]);
        Assert([observable], [qubit], res, $"");
        
        if (res == One) {
            ApplyNonCommutingPauli(observable, qubit);
        }
        
        Assert([observable], [qubit], Zero, $"");
        ApplyNonCommutingPauli(observable, qubit);
        Assert([observable], [qubit], One, $"");
        ApplyNonCommutingPauli(observable, qubit);
    }
    
}



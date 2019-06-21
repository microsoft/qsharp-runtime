// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.TestSuite {
    
    open Microsoft.Quantum.Intrinsic;
    
    
    operation AssertProbOneQubitTest () : Unit {
        
        
        for (i in 1 .. MaxQubitsToAllocateForOneQubitTests()) {
            CheckAllocatedQubitsAreInZeroState(i);
            CheckZeroStateObservablesValues(i);
        }
    }
    
    
    operation CheckAllocatedQubitsAreInZeroState (count : Int) : Unit {
        
        
        using (qs = Qubit[count]) {
            
            for (i in 0 .. count - 1) {
                AssertProb([PauliZ], [qs[i]], Zero, 1.0, $"Newly allocated qubits must be in |0⟩ state", Accuracy());
                Assert([PauliZ], [qs[i]], Zero, $"Newly allocated qubits must be in |0⟩ state");
            }
        }
    }
    
    
    operation CheckZeroStateObservablesValues (count : Int) : Unit {
        
        
        using (qs = Qubit[count]) {
            
            for (i in 0 .. count - 1) {
                AssertProb([PauliX], [qs[i]], Zero, 0.5, $"Measuring I+X for zero state must have probability 0.5", Accuracy());
                AssertProb([PauliX], [qs[i]], One, 0.5, $"Measuring I-X for zero state must have probability 0.5", Accuracy());
                AssertProb([PauliY], [qs[i]], Zero, 0.5, $"Measuring I+Y for zero state must have probability 0.5", Accuracy());
                AssertProb([PauliY], [qs[i]], One, 0.5, $"Measuring I-Y for zero state must have probability 0.5", Accuracy());
            }
        }
    }
    
}



// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.TestSuite {
    
    open Microsoft.Quantum.Intrinsic;
    
    
    operation AssertProbAndCliffordOneQubitTest () : Unit {
        
        let totalQubits = MaxQubitsToAllocateForOneQubitTests();
        
        using (qs = Qubit[totalQubits]) {
            
            for (i in 0 .. totalQubits - 1) {
                let targetQubits = [qs[i]];
                AssertProbAndPaulies(targetQubits);
                AssertProbAndS(Zero, targetQubits);
                AssertProbAndS(One, targetQubits);
                
                if (IsStabilizerSimulator()) {
                    AssertProbAndH(Zero, targetQubits);
                    AssertProbAndH(One, targetQubits);
                }
            }
        }
    }
    
    
    operation AssertProbAndPaulies (qs : Qubit[]) : Unit {
        
        Assert([PauliZ], qs, Zero, $"Newly allocated qubits are always zero");
        X(qs[0]);
        Assert([PauliZ], qs, One, $"");
        X(qs[0]);
        Assert([PauliZ], qs, Zero, $"");
        Y(qs[0]);
        Assert([PauliZ], qs, One, $"");
        Y(qs[0]);
    }
    
    
    operation AssertProbAndH (intial : Result, qs : Qubit[]) : Unit {
        
        
        if (intial == One) {
            X(qs[0]);
        }
        
        Assert([PauliZ], qs, intial, $"Newly allocated qubits are always zero");
        H(qs[0]);
        Assert([PauliX], qs, intial, $"");
        AssertProb([PauliZ], qs, Zero, 0.5, $"", Accuracy());
        AssertProb([PauliY], qs, Zero, 0.5, $"", Accuracy());
        AssertProb([PauliZ], qs, One, 0.5, $"", Accuracy());
        AssertProb([PauliY], qs, One, 0.5, $"", Accuracy());
        H(qs[0]);
        Assert([PauliZ], qs, intial, $"Newly allocated qubits are always zero");
        
        if (intial == One) {
            X(qs[0]);
        }
    }
    
    
    operation AssertProbAndS (intial : Result, qs : Qubit[]) : Unit {
        
        
        if (intial == One) {
            X(qs[0]);
        }
        
        Assert([PauliZ], qs, intial, $"Newly allocated qubits are always zero");
        S(qs[0]);
        Assert([PauliZ], qs, intial, $"");
        S(qs[0]);
        Assert([PauliZ], qs, intial, $"Newly allocated qubits are always zero");
        
        if (intial == One) {
            X(qs[0]);
        }
    }
    
}



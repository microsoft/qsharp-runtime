// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.TestSuite {
    
    open Microsoft.Quantum.Intrinsic;
    
    
    operation ManyControlQubitsTest () : Unit {
        
        let totalQubits = 18;
        
        for (i in 14 .. totalQubits) {
            
            using (qubits = Qubit[i]) {
                
                for (c in 0 .. i - 2) {
                    
                    for (h in 0 .. i - 1) {
                        H(qubits[h]);
                    }
                    
                    let ctrls = qubits[0 .. c];
                    let target = qubits[i - 1];
                    X(ctrls[c]);
                    Controlled X(ctrls, target);
                }
                
                ResetAll(qubits);
            }
        }
    }
    
}



// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.Simulators.Tests.Circuits {
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Diagnostics;
    
    
    operation SwapTest () : Unit {
        
        
        using (qubits = Qubit[2]) {
            let q1 = qubits[0];
            let q2 = qubits[1];
            X(q1);
            SWAP(q1, q2);
            
            // Make sure all allocated qubits are measured before release
            let (r1, r2) = (M(q1), M(q2));
            AssertQubit(Zero, q1);
            AssertQubit(One, q2);
            X(q2);
        }
    }
    
}



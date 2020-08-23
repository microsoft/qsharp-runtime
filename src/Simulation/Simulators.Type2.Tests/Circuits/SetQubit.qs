// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.Simulators.Tests.Circuits {
    
    open Microsoft.Quantum.Intrinsic;
    
    
    operation SetQubit (desired : Result, q1 : Qubit) : Unit {
        
        let current = M(q1);
        
        if (desired != current) {
            X(q1);
        }
    }
    
}



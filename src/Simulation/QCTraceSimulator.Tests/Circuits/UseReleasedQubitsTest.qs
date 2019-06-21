// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.QCTraceSimulatorRuntime.Tests {
    
    open Microsoft.Quantum.Intrinsic;
    
    
    operation UseReleasedQubitTest () : Unit {
        
        mutable q = new Qubit[1];
        
        using (ans = Qubit()) {
            set q = q w/ 0 <- ans;
        }
        
        H(q[0]);
    }
    
}



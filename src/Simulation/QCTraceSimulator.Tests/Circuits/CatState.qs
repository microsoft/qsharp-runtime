// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.QCTraceSimulatorRuntime.Tests {
    
    open Microsoft.Quantum.Intrinsic;
    
    
    operation CatState (powerOfTwo : Int) : Unit {
        
        
        using (qubits = Qubit[2 ^ powerOfTwo]) {
            H(qubits[0]);
            mutable shift = 2 ^ powerOfTwo;
            mutable pow = 1;
            
            for (i in 0 .. powerOfTwo - 1) {
                
                // shift is equal to 2^(powerOfTwo-1-i) here
                set shift = shift / 2;
                
                // pow is equal to 2ⁱ here
                for (j in 0 .. pow - 1) {
                    CNOT(qubits[(2 * j) * shift], qubits[(2 * j + 1) * shift]);
                }
                
                set pow = pow * 2;
            }
        }
    }
    
}



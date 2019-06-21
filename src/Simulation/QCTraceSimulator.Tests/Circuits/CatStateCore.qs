// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.QCTraceSimulatorRuntime.Tests {
    
    open Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators.Implementation;
    
    
    function Power (b : Int, power : Int) : Int {
        
        
        if (power < 0) {
            fail $"power must be positive";
        }
        
        mutable a = 1;
        
        for (j in 0 .. power - 1) {
            set a = a * b;
        }
        
        return a;
    }
    
    
    operation CatStateCore (powerOfTwo : Int) : Unit {
        
        
        using (qubits = Qubit[Power(2, powerOfTwo)]) {
            Interface_Clifford(1, PauliI, qubits[0]);
            mutable shift = Power(2, powerOfTwo);
            mutable pow = 1;
            
            for (i in 0 .. powerOfTwo - 1) {
                
                // shift is equal to 2^(powerOfTwo-1-i) here
                set shift = shift / 2;
                
                // pow is equal to 2ⁱ here
                for (j in 0 .. pow - 1) {
                    Interface_CX(qubits[(2 * j) * shift], qubits[(2 * j + 1) * shift]);
                }
                
                set pow = pow * 2;
            }
        }
    }
    
}



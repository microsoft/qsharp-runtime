// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.Simulators.Tests.Circuits {
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Math;
    
    
    operation IncrementWithRotationsTest (start : Int) : Int {
        
        
        using (qubits = Qubit[3]) {
            for (shift in 0..2) {
                if (((start >>> shift) &&& 1) == 1) {
                    R(PauliX, PI(), qubits[shift]);
                }
            }

            // identity
            R(PauliY, 2.0 * PI(), qubits[2]);
            // controlled identity
            Controlled Rz(qubits[0..0], (4.0 * PI(), qubits[1]));
            Controlled RFrac(qubits[0..1], (PauliX, 2, 0, qubits[2]));

            CCNOT(qubits[0], qubits[1], qubits[2]);
            CNOT(qubits[0], qubits[1]);
            //Rx(PI(), qubits[0]);
            RFrac(PauliX, 1, 1, qubits[0]);

            let b0 = M(qubits[0]) == One ? 1 | 0;
            let b1 = M(qubits[1]) == One ? 1 | 0;
            let b2 = M(qubits[2]) == One ? 1 | 0;

            ResetAll(qubits);

            return b2 * 4 + b1 * 2 + b0;
        }
    }
    
}



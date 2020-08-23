// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.Simulators.Tests.Circuits {
    
    open Microsoft.Quantum.Intrinsic;
    
    
    operation TeleportTest () : Unit {
        
        
        using (qubits = Qubit[3]) {
            let q1 = qubits[0];
            let q2 = qubits[1];
            let q3 = qubits[2];
            
            // create a Bell pair
            H(q1);
            CNOT(q1, q2);
            
            // create quantum state
            H(q3);
            Rz(1.1, q3);
            
            // teleport
            CNOT(q3, q2);
            H(q3);
            Controlled X([q2], q1);
            Controlled Z([q3], q1);
            
            // check teleportation success
            Rz(-1.1, q1);
            H(q1);
            
            // Make sure all allocated qubits are retrurned to zero before release
            ResetAll(qubits);
        }
    }
    
}



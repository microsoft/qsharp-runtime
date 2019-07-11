// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.QCTraceSimulatorRuntime.Tests {
    
    open Microsoft.Quantum.Intrinsic;
    
    
    operation MultiControlledXDriver (numberOfQubits : Int) : Unit {
        
        
        using (qubits = Qubit[numberOfQubits]) {
            Controlled X(qubits[1 .. numberOfQubits - 1], qubits[0]);
        }
    }
    
    
    operation CCNOTDriver () : Unit {
        
        
        using (qubits = Qubit[3]) {
            CCNOT(qubits[0], qubits[1], qubits[2]);
            T(qubits[0]);
        }
    }
    
}



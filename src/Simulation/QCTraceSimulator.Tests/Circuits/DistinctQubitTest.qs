// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.QCTraceSimulatorRuntime.Tests {
    
    open Microsoft.Quantum.Intrinsic;
    
    
    operation DisctinctQubitTest () : Unit {
        
        
        using (q = Qubit[1]) {
            
            // CNOT is not defined when control and target are the same qubit
            CNOT(q[0], q[0]);
        }
    }
    
    
    operation ApplyOp (q : Qubit, op : (Qubit => Unit)) : Unit {
        
        op(q);
    }
    
    
    operation DisctinctQubitCapturedTest () : Unit {
        
        
        using (q = Qubit[2]) {
            let opWithCapturedQubit = CNOT(q[0], _);
            
            // Success
            ApplyOp(q[1], opWithCapturedQubit);
            
            // Error
            ApplyOp(q[0], opWithCapturedQubit);
        }
    }
    
    
    operation DoBoth (q1 : Qubit, q2 : Qubit, op1 : (Qubit => Unit), op2 : (Qubit => Unit)) : Unit {
        
        // when the user looks at the code below they expect it to be no different 
        // from the code below:
        // op2(q1)
        // op1(q2)
        // however, look at the operation DisctinctQubitCaptured2Test. The result 
        // produced by that operation will actually depend on the order in which op1 
        // and op2 are called. To prevent this one should avoid passing non-distinct qubits. 
        op1(q1);
        op2(q2);
    }
    
    
    operation DisctinctQubitCaptured2Test () : Unit {
        
        
        using (q = Qubit[3]) {
            let op1 = CNOT(_, q[1]);
            let op2 = CNOT(q[1], _);
            
            // Error
            DoBoth(q[0], q[2], op1, op2);
        }
    }
    
    
    operation DisctinctQubitCaptured3Test () : Unit {
        
        
        using (q = Qubit[4]) {
            let op1 = CNOT(_, q[0]);
            let op2 = CNOT(q[1], _);
            
            // Success
            DoBoth(q[2], q[3], op1, op2);
            
            // Error
            DoBoth(q[0], q[2], op1, op2);
        }
    }
    
    
    operation DisctinctQubitCaptured4Test () : Unit {
        
        
        using (q = Qubit[5]) {
            let op1 = CNOT(_, q[0]);
            let op2 = Controlled CNOT([q[1]], (q[2], _));
            
            // Success
            DoBoth(q[3], q[4], op1, op2);
            
            // Error
            DoBoth(q[1], q[4], op1, op2);
        }
    }
    
}



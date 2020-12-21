// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.TestSuite {
    
    open Microsoft.Quantum.Intrinsic;
    
    
    ///<summary>
    /// Test helper to be used with AssertOperationsEqualInPlace and AssertOperationsEqualReferenced
    /// if one needs to check that the operation is identity
    ///</summary>
    operation IdentityTestHelper (q : Qubit[]) : Unit {
        
        body (...) {
        }
        
        adjoint invert;
        controlled distribute;
        controlled adjoint distribute;
    }
    
    
    operation OnFirstQubit (op : (Qubit => Unit), qubits : Qubit[]) : Unit {
        
        op(qubits[0]);
    }
    
    
    operation OnFirstQubitA (op : (Qubit => Unit is Adj), qubits : Qubit[]) : Unit {
        
        body (...) {
            op(qubits[0]);
        }
        
        adjoint invert;
    }
    
    
    operation OnFirstQubitAC (op : (Qubit => Unit is Adj + Ctl), qubits : Qubit[]) : Unit {
        
        body (...) {
            op(qubits[0]);
        }
        
        adjoint invert;
        controlled distribute;
        controlled adjoint distribute;
    }
    
    
    operation OnSecondQubitAC (op : (Qubit => Unit is Adj + Ctl), qubits : Qubit[]) : Unit {
        
        body (...) {
            op(qubits[1]);
        }
        
        adjoint invert;
        controlled distribute;
        controlled adjoint distribute;
    }
    
    
    operation OnFirstTwoQubitsAC (op : ((Qubit, Qubit) => Unit is Adj + Ctl), qubits : Qubit[]) : Unit {
        
        body (...) {
            op(qubits[0], qubits[1]);
        }
        
        adjoint invert;
        controlled distribute;
        controlled adjoint distribute;
    }
    
    
    operation OnFirstThreeQubitsAC (op : ((Qubit, Qubit, Qubit) => Unit is Adj + Ctl), qubits : Qubit[]) : Unit {
        
        body (...) {
            op(qubits[0], qubits[1], qubits[2]);
        }
        
        adjoint invert;
        controlled distribute;
        controlled adjoint distribute;
    }
    
    
    operation OnOneQubit (op : (Qubit[] => Unit), qubit : Qubit) : Unit {
        
        op([qubit]);
    }
    
    
    operation OnOneQubitA (op : (Qubit[] => Unit is Adj), qubit : Qubit) : Unit {
        
        body (...) {
            op([qubit]);
        }
        
        adjoint invert;
    }
    
    
    operation OnOneQubitAC (op : (Qubit[] => Unit is Adj + Ctl), qubit : Qubit) : Unit {
        
        body (...) {
            op([qubit]);
        }
        
        adjoint invert;
        controlled distribute;
        controlled adjoint distribute;
    }
    
}



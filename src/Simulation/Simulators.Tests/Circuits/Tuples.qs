// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Tests.OperationNames {
    
    operation Name () : Unit {
        
    }
    
    
    operation Variant () : Unit {
        
    }
    
    
    operation DataIn () : Unit {
        
    }
    
    
    operation DataOut () : Unit {
        
    }
    
}


namespace Microsoft.Quantum.Tests.Tuples {
    
    newtype Q = Qubit;
    
    newtype I = Int;
    
    newtype TupleA = (Int, Pauli, Qubit, (Qubit, Int, Qubit));
    
    newtype TupleB = ((Int, Int), (Qubit, (Int, (Qubit, Qubit)), Double));
    
    newtype TupleC = (Qubit, TupleB);
    
    newtype TupleD = Qubit[];
    
    newtype TupleE = (Int, Qubit[]);
    
    newtype TupleF = ((TupleA, TupleD) => Unit is Adj + Ctl);
    
    newtype TupleG = (Qubit, TupleF, TupleC, TupleD);
    
    newtype TupleH = (TupleD, TupleG);
    
    newtype TupleI = ((TupleD, TupleF) -> TupleD);
    
    newtype TupleJ = (Int, Qubit)[];
    
    newtype Name = String;
    
    newtype Variant = String;
    
    newtype DataIn = (Int, Qubit);
    
    newtype DataOut = (Int, (Qubit, Qubit));
    
    
    operation Op1 (a : TupleA, d : TupleD) : Unit {
        
        body (...) {
        }
        
        adjoint invert;
        controlled distribute;
        controlled adjoint distribute;
    }
    
    
    function F1 (d : TupleD, f : TupleF) : TupleD {
        
        return d;
    }
    
}



// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

// This files contains ClosedType version of operations that can normally be implemented
// with generics to verify that they can be used interchangeably.

namespace Microsoft.Quantum.Simulation.Simulators.Tests.Circuits.ClosedType {
    
    open Microsoft.Quantum.Intrinsic;
    
    
    newtype Qs = Qubit[];
    
    newtype UDT_C2 = (String, Int, Double);
    
    newtype UDT_C3 = (String, (Double, Pauli), Result);
    
    
    operation AsString (v : Result) : String {
        
        
        if (v == One) {
            return $"uno";
        }
        else {
            return $"cero";
        }
    }
    
    
    operation Trace (tag : String) : Unit {
        body intrinsic;
        adjoint intrinsic;
        controlled intrinsic;
        controlled adjoint intrinsic;
    }
    
    
    operation TraceGate (gate : (Qubit => Unit is Adj + Ctl), tag : String, qubit : Qubit) : Unit {
        
        body (...) {
            Trace(tag);
            gate(qubit);
        }
        
        adjoint invert;
        controlled distribute;
        controlled adjoint distribute;
    }
    
    
    operation ClosedType2 (tag : (String, Int, Double)) : Unit {
        
        body (...) {
            let (msg, i, d) = tag;
            Trace(msg);
        }
        
        adjoint invert;
    }
    
    
    operation ClosedType3 (tag : (String, (Double, Pauli), Result)) : Unit {
        
        body (...) {
            let (msg, t, r) = tag;
            Trace(msg);
        }
        
        controlled distribute;
    }
    
    
    operation ClosedType4 (r1 : Result, (t1 : String, t2 : Int), r2 : Result) : Unit {
        
        body (...) {
            Trace(t1);
        }
        
        adjoint invert;
        controlled distribute;
        controlled adjoint distribute;
    }
    
    
    operation ClosedType5 (tag : (String, Int, Double, Result)) : Unit {
        
        body (...) {
            let (msg, i, d, r) = tag;
            Trace(msg);
        }
        
        adjoint invert;
        controlled distribute;
        controlled adjoint distribute;
    }
    
    
    operation Map (mapper : (Result => String), source : Result[]) : String[] {
        
        mutable result = new String[Length(source)];
        
        for (i in 0 .. Length(source) - 1) {
            let m = mapper(source[i]);
            set result = result w/ i <- m;
        }
        
        return result;
    }
    
    
    operation Iter (callback : (String => Unit), source : String[]) : Unit {
        
        
        for (i in 0 .. Length(source) - 1) {
            callback(source[i]);
        }
    }
    
    
    operation Repeat (callback : (Qubit => Unit is Adj + Ctl), bodyCount : Int, adjointCount : Int, controlledCount : Int, source : Qubit) : Unit {
        
        body (...) {
            
            for (i in 1 .. bodyCount) {
                callback(source);
            }
            
            for (i in 1 .. adjointCount) {
                Adjoint callback(source);
            }
            
            for (i in 1 .. controlledCount) {
                
                using (ctrls = Qubit[1]) {
                    Controlled callback(ctrls, source);
                }
            }
        }
        
        adjoint invert;
    }
    
    
    operation TestIter () : Unit {
        
        let ctrls = new Qubit[2];
        let a = [One, Zero, Zero];
        Iter(Trace, Map(AsString, a));
        let b = [One, One, Zero, Zero, Zero];
        Iter(Adjoint Trace, Map(AsString, b));
        let c = [One, Zero, One, One];
        let ctrlOp = Controlled Trace(ctrls, _);
        Iter(ctrlOp, Map(AsString, c));
        let d = [One, Zero, One, Zero, One, Zero, One, Zero, One];
        let ctrlAdjOp = Adjoint Controlled Trace(ctrls, _);
        Iter(ctrlAdjOp, Map(AsString, d));
    }
    
    
    operation TestRepeatPartial () : Unit {
        
        let p1 = Repeat(_, 5, 2, _, _);
        let p2 = p1(_, 3, _);
        
        using (qubits = Qubit[1]) {
            p2(TraceGate(X, $"normal", _), qubits[0]);
            Adjoint p2(TraceGate(X, $"adjoint", _), qubits[0]);
        }
    }
    
    
    operation TestUDTsUnwrapping () : Unit {
        
        let d2a = ($"d2a", 2, 2.0);
        let d2b = ($"d2b", 2, 2.0);
        let u2c = UDT_C2(d2b);
        let d2x = ($"d2x", 2, 2.0);
        let d2y = ($"d2y", 2, 2.0);
        let u2x = UDT_C2(d2x);
        let u2y = UDT_C2(d2y);
        
        using (ctrls = Qubit[1]) {
            let qs = Qs(ctrls);
            ClosedType2(d2a);
            ClosedType2((UDT_C2(d2b))!);
            Adjoint ClosedType2(d2a);
            Adjoint ClosedType2(u2c!);
            let p = ClosedType5(_, _, _, One);
            p(d2x);
            p((UDT_C2(d2y))!);
            Adjoint p(d2x);
            Adjoint p(u2y!);
            Controlled p(ctrls, u2x!);
            Controlled p((Qs(ctrls))!, u2y!);
            Adjoint Controlled p(qs!, u2x!);
            Adjoint Controlled p(ctrls, u2y!);
        }
    }
    
}



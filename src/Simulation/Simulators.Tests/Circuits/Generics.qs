// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

// This files contains Generic version of gates in ClosedTypes.qb
// to verify that they can be used interchangeably.

namespace Microsoft.Quantum.Simulation.Simulators.Tests.Circuits.Generics {
    
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Simulation.Simulators.Tests.Circuits;
    
    
    newtype UDT_G1 = (Int, Qubit);
    
    newtype UDT_G2 = (Qubit, Qubit);
    
    newtype UDT_G3 = (Bool[], Qubit);
    
    newtype UDT_G4 = (Bool[], Int, Qubit);
    
    newtype UDT_G5 = (UDT_G1, UDT_G2);
    
    newtype UDT_G6 = (UDT_G1[], UDT_G2);
    
    newtype UDT_G7 = UDT_G1;
    
    newtype LittleEndian = Qubit[];
    
    
    operation AsString (v : Result) : String {
        
        if (v == One) {
            return $"uno";
        }
        else {
            return $"cero";
        }
    }
    
    
    operation Trace<'T> (tag : 'T) : Unit
    is Adj + Ctl {
        body intrinsic;
    }
    
    
    operation Gen0<'I> (tag : 'I) : Unit 
    is Adj + Ctl {
        Trace(tag);
    }
    
    
    operation Gen1<'I, 'O> (i : 'I, o : 'O) : 'O {
        
        Trace(i, o);
        return o;
    }
    
    
    operation Gen2<'T1, 'T2> (tag : ('T1, Int, 'T2)) : Unit 
    is Adj {
        Trace(tag);
    }
    
    
    operation Gen3<'T1, 'T2, 'T3> (tag : ('T1, ('T2, 'T3), Result)) : Unit 
    is Ctl {
        Trace(tag);
    }
    
    
    operation Gen4<'T1, 'T2> (r1 : Result, (t1 : 'T1, t2 : 'T2), r2 : Result) : Unit 
    is Adj + Ctl {
        Trace(r1, (t1, t2), r2);
    }
    
    
    operation Gen5<'I> (tags : 'I[]) : Unit 
    is Adj + Ctl {
        
        for (i in 0 .. Length(tags) - 1) {
            Trace(tags[i]);
        }
    }
    
    
    operation Gen6<'I> (data : ((Int, 'I)[], (Qubit, Qubit))) : Unit
    is Adj + Ctl {        
        let (tags, qubits) = data;
            
        for (i in 0 .. Length(tags) - 1) {
            Trace(tags[i]);
        }
    }
    
    
    operation Gen7<'I> (data : (Int, 'I[])) : Unit 
    is Adj + Ctl {
        let (index, tags) = data;
            
        for (i in 0 .. Length(tags) - 1) {
            Trace(tags[i]);
        }
    }
    
    
    operation TraceGate<'T> (gate : (Qubit => Unit is Adj + Ctl), tag : 'T, qubit : Qubit) : Unit 
    is Adj + Ctl {
        Trace(tag);
        gate(qubit);
    }
    
    
    operation Map<'T, 'U> (mapper : ('T => 'U), source : 'T[]) : 'U[] {
        
        mutable result = new 'U[Length(source)];
        
        for (i in 0 .. Length(source) - 1) {
            let m = mapper(source[i]);
            set result = result w/ i <- m;
        }
        
        return result;
    }
    
    
    operation Iter<'T> (callback : ('T => Unit), source : 'T[]) : Unit {
        
        for (i in 0 .. Length(source) - 1) {
            callback(source[i]);
        }
    }
    
    
    operation Repeat<'T> (callback : ('T => Unit is Adj + Ctl), bodyCount : Int, adjointCount : Int, controlledCount : Int, source : 'T) : Unit 
    is Adj {
        let r = 1 .. bodyCount;
            
        for (i in r) {
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
    
    
    operation TestIter () : Unit {
        
        using (ctrls = Qubit[2]) {
            let a = [One, Zero, Zero];
            Iter(Trace<Result>, a);
            Iter(Trace<String>, Map(AsString, a));
            let b = [One, One, Zero, Zero, Zero];
            Iter(Adjoint Trace<Result>, b);
            Iter(Adjoint Trace<String>, Map(AsString, b));
            let c = [One, Zero, One, One];
            let ctrlOpResult = Controlled Trace<Result>(ctrls, _);
            let ctrlOpString = Controlled Trace<String>(ctrls, _);
            Iter(ctrlOpResult, c);
            Iter(ctrlOpString, Map(AsString, c));
            let d = [One, Zero, One, Zero, One, Zero, One, Zero, One];
            let ctrlAdjOpResult = Adjoint Controlled Trace<Result>(ctrls, _);
            let ctrlAdjOpString = Adjoint Controlled Trace<String>(ctrls, _);
            Iter(ctrlAdjOpResult, d);
            Iter(ctrlAdjOpString, Map(AsString, d));
            Iter(X, ctrls);
            Iter(Adjoint X, ctrls);
        }
    }
    
    
    operation TestRepeatPartial () : Unit {
        
        let p1 = Repeat<Qubit>(_, 5, 2, _, _);
        let p2 = p1(_, 3, _);
        
        using (qubits = Qubit[1]) {
            p2(TraceGate(X, $"normal", _), qubits[0]);
            Adjoint p2(TraceGate(X, $"adjoint", _), qubits[0]);
        }
    }
    
    
    operation RepeatWrapper (callback : (Qubit => Unit is Adj + Ctl)) : ((Int, Int, Int, Qubit) => Unit is Adj) {
        
        return Repeat(callback, _, _, _, _);
    }
    
    
    operation TestCreateRepeatWrapperPartial () : Unit {
        
        using (qubits = Qubit[1]) {
            let traceNormal = TraceGate(X, $"normal", _);
            let traceAdjoint = TraceGate(X, $"adjoint", _);
            let normal = ((RepeatWrapper(traceNormal))(_, 2, _, _))(5, 3, _);
            let adj = Adjoint ((RepeatWrapper(traceAdjoint))(5, 2, _, _))(3, _);
            normal(qubits[0]);
            adj(qubits[0]);
        }
    }
    
    
    function ItemAt<'T> (i : Int, array : 'T[]) : 'T {
        
        return array[i];
    }
    
    
    function CreateLookup<'T> (array : 'T[]) : (Int -> 'T) {
        
        return ItemAt(_, array);
    }
    
    
    operation DoAll<'T> (lookup : (Int -> ('T => Unit is Adj + Ctl)), range : Range, target : 'T) : Unit 
    is Adj + Ctl {
            
        using (ctrls = Qubit[2]) {
                
            for (i in range) {
                let op = lookup(i);
                op(target);
                Adjoint op(target);
                Controlled op(ctrls, target);
            }
        }
    }
    
    
    operation TestLookupUnitaries () : Unit {
        
        let traceLookup = CreateLookup([Trace<String>, Trace<String>, Trace<String>]);
        let xLookup = CreateLookup([X, X, X, X]);
        let range = 0 .. 2;
        
        using (ctrls = Qubit[1]) {
            DoAll(traceLookup, range, $"uno");
            Adjoint DoAll(traceLookup, range, $"uno");
            Controlled DoAll(ctrls, (traceLookup, range, $"uno"));
            
            using (qubits = Qubit[1]) {
                DoAll(xLookup, range, qubits[0]);
                Controlled DoAll(ctrls, (xLookup, range, qubits[0]));
            }
        }
    }
    
    
    operation NestedArgTuple (a : (String, String), (b : Int, (c : Int, d : (Result, Result)), e : String)) : Unit 
    is Adj + Ctl {

        Trace(a);
        Trace(b);
        Trace(c);
        Trace(d);
        Trace(e);
        let (a1, a2) = a;
        Trace(a1);
        Trace(a2);
        let (d1, d2) = d;
        Trace(d1);
        Trace(d2);
    }
    
    
    operation NestedArgTupleParameter (op : (((String, String), (Int, (Int, (Result, Result)), String)) => Unit is Adj + Ctl), a : (String, String), b : Int, c : Int, d : (Result, Result), e : String) : Unit {
        
        using (qubits = Qubit[2]) {
            let (a1, a2) = a;
            let (d1, d2) = d;
            let p1A = op(a, (b, (_, d), _));
            let p2A = p1A(c, _);
            p1A(c, e);
            Adjoint p1A(c, e);
            Controlled (Adjoint p1A)(qubits, (c, e));
            p2A(e);
            Adjoint p2A(e);
            Adjoint Controlled p2A(qubits, e);
            let p1B = Controlled op(_, ((a1, _), (b, (c, (_, _)), _)));
            let p2B = p1B(qubits, (a2, (_, _)));
            let p3B = p2B(d, _);
            p1B(qubits, (a2, (d, e)));
            p1B(qubits[0 .. 1], (a2, ((d1, d2), e)));
            Adjoint p2B(d, e);
            Controlled p2B(qubits, ((d1, d2), e));
            Controlled (Adjoint p3B)(qubits, e);
        }
    }
    
    
    operation TestNonGenericPartial () : Unit {
        
        let a = ($"a1", $"a2");
        let (a1, a2) = a;
        let b = 2;
        let c = 3;
        let d = (Zero, One);
        let (d1, d2) = d;
        let e = $"e";
        let p1A = NestedArgTuple(a, (b, (_, d), _));
        let p2A = p1A(c, _);
        p1A(c, e);
        Adjoint p1A(c, e);
        p2A(e);
        Adjoint p2A(e);
        let p1B = Adjoint NestedArgTuple((a1, _), (b, (c, (_, _)), _));
        let p2B = p1B(a2, (_, _));
        let p3B = p2B(d, _);
        p1B(a2, (d, e));
        p1B(a2, ((d1, d2), e));
        p2B(d, e);
        p2B((d1, d2), e);
        p3B(e);
        Adjoint p1B(a2, (d, e));
        Adjoint p2B(d, e);
        Adjoint p3B(e);
        NestedArgTupleParameter(NestedArgTuple, a, b, c, d, e);
    }
    
    
    operation NestedArgTupleGeneric<'A, 'B, 'C> (a : ('A, Int), (b : 'B, (c : Int, d : (Result, 'C)), e : Double)) : Unit {
        
        let (a1, a2) = a;
        
        // a1 is arg of type 'A
        Trace(a1);
        
        // b is arg of type 'B
        Trace(b);
        let (d1, d2) = d;
        
        // d2 is arg of type 'C
        Trace(d2);
    }
    
    
    operation TestGenericPartial () : Unit {
        
        let a = ($"argA", 0);
        let (a1, a2) = a;
        let b = $"argB";
        let c = 0;
        let d = (Zero, $"argD");
        let (d1, d2) = d;
        let e = 0.0;
        let stringTuple = ($"T1", $"T2");
        
        // NestedArgTupleGeneric (a, (b, (c, d), e));
        let p1A = NestedArgTupleGeneric(a, (b, (_, d), _));
        p1A(c, e);
        let p1B = NestedArgTupleGeneric((stringTuple, a2), (b, (_, d), _));
        p1B(c, e);
        let p1C = NestedArgTupleGeneric(a, (stringTuple, (_, d), _));
        p1C(c, e);
        let p1D = NestedArgTupleGeneric(a, (b, (_, (d1, stringTuple)), _));
        p1D(c, e);
        let p2A = NestedArgTupleGeneric<String, String, String>(_, (_, (c, d), e));
        p2A(a, b);
        let p2B = NestedArgTupleGeneric<(String, String), String, String>(_, (_, (c, d), e));
        p2B((stringTuple, a2), b);
        let p2C = NestedArgTupleGeneric<String, (String, String), String>(_, (_, (c, d), e));
        p2C(a, stringTuple);
        let p2D = NestedArgTupleGeneric<String, String, (String, String)>(_, (_, (c, (d1, stringTuple)), e));
        p2D(a, b);
        let p3A = NestedArgTupleGeneric<String, String, String>(a, (_, (_, _), e));
        p3A(b, (c, d));
        let p3B = NestedArgTupleGeneric<(String, String), String, String>((stringTuple, a2), (_, (_, _), e));
        p3B(b, (c, d));
        let p3C = NestedArgTupleGeneric<String, (String, String), String>(a, (_, (_, _), e));
        p3C(stringTuple, (c, d));
        let p3D = NestedArgTupleGeneric<String, String, (String, String)>(a, (_, (_, _), e));
        p3D(b, (c, (d1, stringTuple)));
        
        // Inner partials:
        let p4A = NestedArgTupleGeneric<String, String, String>(a, (_, (_, _), e));
        let p4Aa = p4A(b, (_, _));
        p4Aa(c, d);
        let p4B = NestedArgTupleGeneric<String, String, String>(a, (_, (_, _), e));
        let p4Ba = p4B(b, (c, _));
        p4Ba(One, $"otherD");
        return ();
    }
    
    
    operation BindTest () : Unit {
        let bound = Bind([X, X, X]);
        
        // FIXME: switched the second argument from ApplyToEach(..) to ApplyToEachA(..)
        AssertOperationsEqualReferenced(ApplyToEach<Qubit>(bound, _), ApplyToEachA<Qubit>(X, _), 3);
    }
    
    
    operation BindImpl<'T> (operations : ('T => Unit is Adj + Ctl )[], target : 'T) : Unit {
        
        for (idxOperation in 0 .. Length(operations) - 1) {
            let op = operations[idxOperation];
            op(target);
        }
    }
    
    
    function Bind<'T> (operations : ('T => Unit is Adj + Ctl)[]) : ('T => Unit) {
        
        return BindImpl(operations, _);
    }
    
    
    operation ApplyToEachA<'T> (singleQubitOperation : ('T => Unit is Adj), register : 'T[]) : Unit 
    is Adj {
        
        for (idxQubit in 0 .. Length(register) - 1) {
            singleQubitOperation(register[idxQubit]);
        }
    }
    
    
    operation ApplyToEach<'T> (singleQubitOperation : ('T => Unit), register : 'T[]) : Unit {
        
        for (idxQubit in 0 .. Length(register) - 1) {
            singleQubitOperation(register[idxQubit]);
        }
    }
    
    
    operation ApplyToEachCA<'T> (singleQubitOperation : ('T => Unit is Adj + Ctl), register : 'T[]) : Unit
    is Adj + Ctl {
        
        for (idxQubit in 0 .. Length(register) - 1) {
            singleQubitOperation(register[idxQubit]);
        }
    }
    
    
    operation AssertOperationsEqualReferenced (actual : (Qubit[] => Unit), expected : (Qubit[] => Unit is Adj), nQubits : Int) : Unit {
        
        using (qs = Qubit[2]) {
            Adjoint expected(qs);
            actual(qs);
        }
        
        Trace($"success!");
    }
    
    
    operation CCNOT2OuterCircuit (qs : Qubit[]) : Unit 
    is Adj + Ctl { }
    
    
    operation UpToPhaseCCNOT2 (control1 : Qubit, control2 : Qubit, target : Qubit) : Unit
    is Adj {
        WithA(CCNOT2OuterCircuit, [target, control1, control2]);
    }
    
    
    operation WithA<'T> (outerOperation : ('T => Unit is Adj), target : 'T) : Unit 
    is Adj {}
    
    
    operation CCNOTCiruitsTest () : Unit {
        
        using (qubits = Qubit[3]) {
            Adjoint UpToPhaseCCNOT2(qubits[0], qubits[1], qubits[2]);
        }
        
        Trace($"success!");
    }
    
    
    operation CountQs<'T> (qs : 'T[]) : Unit
    is Adj {
        
        body (...) {
            Trace(Length(qs));
        }
        
        controlled (cs, ...) {
            Trace(Length(qs) + Length(cs));
        }
    }
    
    
    operation CountQsNonGeneric (qs : Qubit[]) : Unit 
    is Adj {
        
        body (...) {
            Trace(Length(qs));
        }
        
        controlled (cs, ...) {
            Trace(Length(qs + cs));
        }
    }
    
    
    operation MultiControlledTest () : Unit {
        
        using (qs = Qubit[1]) {
            using (cs1 = Qubit[1]) {
                using (cs2 = Qubit[1]) {                    
                    using (cs3 = Qubit[1]) {
                        CountQs(qs);
                        Controlled CountQs(cs1, qs);
                        Controlled (Controlled CountQs)(cs1, (cs2, qs));
                        Controlled (Controlled (Controlled CountQs))(cs1, (cs2, (cs3, qs)));
                    }
                }
            }
        }
    }
    
    
    operation MixedComponentsTest () : Unit {
        
        using (qs = Qubit[1]) {            
            using (cs1 = Qubit[1]) {
                using (cs2 = Qubit[1]) {
                    Adjoint (Adjoint CountQs)(qs);
                    Controlled (Adjoint CountQs)(cs1, qs);
                    Adjoint Controlled (Adjoint CountQs)(cs1, qs);
                    Controlled (Controlled (Adjoint CountQs))(cs1, (cs2, qs));
                }
            }
        }
    }
    
    
    function AddControlled<'A> (op : ('A => Unit is Adj + Ctl)) : ((Qubit[], 'A) => Unit is Adj + Ctl) {
        
        return Controlled op;
    }
    
    
    function ReturnId<'A> (arg : 'A) : 'A {
        
        return arg;
    }
    
    
    operation AssignmentsTest () : Unit {
                
        using (qs = Qubit[1]) {
            using (cs1 = Qubit[1]) {                
                using (cs2 = Qubit[1]) {
                    let AAOp = Adjoint (Adjoint CountQs<Qubit>);
                    AAOp(qs);
                    (ReturnId(Controlled (Adjoint CountQs)))(cs1, qs);
                    let CCAOp = AddControlled(Controlled (Adjoint CountQs<Qubit>));
                    CCAOp(cs1, (cs2, qs));
                    Adjoint CCAOp(cs1, (cs2, qs));
                    let CCANGOp = AddControlled(Controlled (Adjoint CountQsNonGeneric));
                    CCANGOp(cs1, (cs2, qs));
                    Adjoint CCANGOp(cs1, (cs2, qs));
                }
            }
        }
    }
    
    
    operation AssignmentsWithPartialsTest () : Unit {
        
        using (qs = Qubit[1]) {
            using (cs1 = Qubit[1]) {
                using (cs2 = Qubit[1]) {
                    let Op1 = (ReturnId(Controlled (Adjoint CountQs<Qubit>)))(cs1, _);
                    Op1(qs);
                    let CCAOpFull = AddControlled(Controlled (Adjoint CountQs<Qubit>));
                    let CCAOp = CCAOpFull(_, (cs2, _));
                    Adjoint CCAOp(cs1, qs);
                    Adjoint (CCAOp(cs1, _))(qs);
                    let CCANGOpFull = AddControlled(Controlled (Adjoint CountQsNonGeneric));
                    let CCANGOp = CCANGOpFull(cs1, _);
                    Adjoint CCANGOp(cs2, qs);
                }
            }
        }
    }
    
    
    function Indirection<'A> (arg : 'A) : 'A[] {
        
        mutable arr = new 'A[5];
        
        for (i in 0 .. Length(arr) - 1) {
            set arr = arr w/ i <- arg;
        }
        
        return arr;
    }
    
    
    function MapDefaults<'T> (fct : ('T -> Unit), dummy : 'T) : Unit {
        
        let arr = new 'T[5];
        let fcts = Indirection(fct);
        
        for (i in 0 .. Length(arr) - 1) {
            fcts[i](arr[i]);
        }
    }
    
    
    function Mapper (i : Int) : Unit {
        
        return ();
    }
    
    
    operation TestMapDefaults () : Unit {
        
        MapDefaults(Mapper, 1);
        Trace($"success!");
    }
    
    
    function ChooseFirst<'A, 'B, 'C> ((a : 'A, b : 'B), c : 'C) : 'A {
        
        return a;
    }
    
    
    operation TypeParameters<'A, 'B> (a : ('A, 'B), b : 'B, c : 'B, d : (('A, 'A), 'B)) : Unit
    is Adj {
        
        body (...) {
            Trace(ChooseFirst(d));
        }
        
        controlled (cs, ...) {
            Trace(b, c);
        }
    }
    
    
    operation TestMultipleTypeParamters () : Unit {
        
        let a = (2, Zero);
        let b = One;
        let d = ((1, 3), One);
        TypeParameters(a, b, b, d);
    }
    
    
    operation TestDestructingArgTuple () : Unit {
        
        let a = (2, Zero);
        let b = One;
        let d = ((1, 3), One);
        let arg = (a, b, b, d);
        TypeParameters(arg);
        let stringArg = (new Qubit[0], ((2, $""), $"Hello", $"World", ((2, 2), $"")));
        Controlled TypeParameters(stringArg);
        Controlled (Adjoint TypeParameters)(stringArg);
    }
    
    
    operation ComposeImpl<'A, 'B> (second : ('A => Unit), first : ('B => 'A), arg : 'B) : Unit {
        
        second(first(arg));
    }
    
    
    operation Compose<'A, 'B> (second : ('A => Unit), first : ('B => 'A)) : ('B => Unit) {
        
        return ComposeImpl(second, first, _);
    }
    
    
    operation TestCompose () : Unit {
        
        let fct = Compose(Trace<String>, AsString);
        fct(Zero);
    }
    
    
    operation TraceNonGeneric (tag : String) : Unit
    is Adj + Ctl {
        
        let arg = $"redirecting:" + tag;
        Trace(arg);
    }
    
    
    operation TestComposeWithNonGeneric () : Unit {
        
        let fct = Compose(TraceNonGeneric, AsString);
        fct(Zero);
    }
    
    
    operation WithCA<'T> (outerOperation : ('T => Unit is Adj), innerOperation : ('T => Unit is Adj + Ctl), target : 'T) : Unit 
    is Adj {
        
        body (...) {
            outerOperation(target);
            innerOperation(target);
            Adjoint outerOperation(target);
        }
        
        controlled (controlRegister, ...) {
            outerOperation(target);
            Controlled innerOperation(controlRegister, target);
            Adjoint outerOperation(target);
        }
    }
    
    
    operation ApplyPauliFromBitString (pauli : Pauli, bitApply : Bool, bits : Bool[], qubits : Qubit[]) : Unit
    is Adj + Ctl {        
        let nBits = Length(bits);
            
        for (idxBit in 0 .. nBits - 1) {
                
            if (bits[idxBit] == bitApply) {
                X(qubits[idxBit]);
                Trace(idxBit);
            }
        }
    }
    
    
    operation ControlledOnBitStringImpl<'T> (bits : Bool[], oracle : ('T => Unit is Adj + Ctl), controlRegister : Qubit[], targetRegister : 'T) : Unit
    is Adj + Ctl {        
        WithCA(ApplyPauliFromBitString(PauliX, false, bits, _), Controlled oracle(_, targetRegister), controlRegister);
    }
    
    
    function ControlledOnBitString<'T> (bits : Bool[], oracle : ('T => Unit is Adj + Ctl)) : ((Qubit[], 'T) => Unit is Adj + Ctl) {
        
        return ControlledOnBitStringImpl(bits, oracle, _, _);
    }
    
    
    // This tests that we can use UDT (that maps to a Q[]) as a controlled parameter.
    
    operation TestControlledBitString () : Unit {
        
        using (data = Qubit[3]) {
            let bits = [false, true, false];
            
            // this is key... allows to tes UDTs as input for partials that expects qubits.
            // (not supported in 0.3+ without unwrapping...)
            let qubits = LittleEndian(data);
            (ControlledOnBitString(bits, Trace))(qubits!, $"ok");
        }
    }
    
    
    // This tests that we can use an UDT (that maps to a Q[]) as input where a Q[] is expected.
    
    operation TestApplyToEachUdt () : Unit {
        
        using (data = Qubit[3]) {
            
            using (control = Qubit[1]) {
                let q0 = Gen1(0, data[0]);
                let q1 = Gen1((UDT_G1(1, data[1]))!);
                let q2 = Gen1((UDT_G7(UDT_G1(2, data[2])))!!);
                let qubits = LittleEndian([q0, q1, q2]);
                Controlled (ApplyToEachCA<Qubit>(Trace<Qubit>, _))(control, qubits!);
            }
        }
    }
    
    
    function UnboxG1Array (data : UDT_G1[]) : (Int, Qubit)[] {
        
        let count = Length(data);
        mutable result = new (Int, Qubit)[count];
        
        for (i in 0 .. count - 1) {
            let (n, q) = data[i]!;
            set result = result w/ i <- (n, q);
        }
        
        return result;
    }
    
    
    function UnboxG6 (data : UDT_G6) : ((Int, Qubit)[], (Qubit, Qubit)) {
        
        let (u1, u2) = data!;
        let (q1, q2) = u2!;
        return (UnboxG1Array(u1), (q1, q2));
    }
    
    
    operation TestUDTsPolyMorphism () : Unit {
        
        
        using (data = Qubit[3]) {
            
            using (control = Qubit[1]) {
                let q0 = Gen1(0, data[0]);
                let q1 = Gen1((UDT_G1(1, data[1]))!);
                let q2 = Gen1((UDT_G7(UDT_G1(2, data[2])))!!);
                let qubits = LittleEndian([q0, q1, q2]);
                let u1 = UDT_G1(1, qubits![1]);
                let u2 = UDT_G2(q2, qubits![2]);
                let u1s = [u1];
                let u2s = [u2, u2];
                let u6 = UDT_G6(u1s, u2);
                let u7 = UDT_G7(u1);
                let u7s = [u7];
                
                //Gen5<'I>(tags: 'I[])
                Gen5(data);
                Gen5(qubits!);
                Gen5(u1s);
                Gen5(u2s);
                Gen5(u7s);
                
                //Gen6<'I>(tags: ((Int, 'I)[], (Qubit, Qubit))
                // TODO: Automatic unboxing for Arrays... Gen6(u1s, (q0, q1));
                // TODO: Automatic unboxing for Arrays... Gen6(u1s, u2);
                // TODO: Automatic unboxing for Arrays... Gen6(u6);
                Gen6([(1, [q1]), (2, [q1, q2])], (q0, q1));
                Gen6([(1, u1s), (2, u1s)], u2!);
                Gen6(UnboxG6(u6));
                
                //Gen7<'I>(tags: (Int, 'I[]))
                Gen7(1, u1s);
                Gen7(2, u7s);
            }
        }
    }
    
    
    function AsStr (r : Result) : String {
        
        if (r == One) {
            return $"One";
        }
        
        return $"Zero";
    }
    
    
    function AsInt (r : Result) : Int {
        
        
        if (r == One) {
            return 1;
        }
        
        return 0;
    }
    
    
    function GenWrapper<'U, 'V> (op : ('U -> 'V), arg : 'U) : 'V {
        
        return op(arg);
    }
    
    
    operation WrapperWithDifferentReturnValuesTest () : Unit {
        
        let str0 = GenWrapper(AsStr, Zero);
        let str1 = GenWrapper(AsStr, One);
        let int0 = GenWrapper(AsInt, Zero);
        let int1 = GenWrapper(AsInt, One);
        let intOp = GenWrapper(AsInt, _);
        let strOp = GenWrapper(AsStr, _);
        AssertEqual($"One", str1);
        AssertEqual($"Zero", str0);
        AssertEqual($"One", strOp(One));
        AssertEqual($"Zero", strOp(Zero));
        AssertEqual(0, int0);
        AssertEqual(1, int1);
        AssertEqual(0, intOp(Zero));
        AssertEqual(1, intOp(One));
    }
    
}



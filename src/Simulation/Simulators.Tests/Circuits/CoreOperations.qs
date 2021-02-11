// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Tests.CoreOperations {
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Simulation.Simulators.Tests.Circuits.Generics;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Math;
    
    
    newtype Q = Qubit;
    
    newtype Qs = Qubit[];
    
    newtype T1 = (Qubit, Qubit);
    
    newtype T2 = (Qubit, Qubit[]);
    
    newtype T3 = (Qubit[], Qs);
    
    newtype T4 = (Int, (Double, Bool, Result));
    
    newtype T5 = (Pauli, Qubit[], Qs, Q);
    
    newtype Plain1 = ((Qubit, Qubit) => Unit);
    
    newtype Adj1 = ((Qubit, Qubit) => Unit is Adj);
    
    newtype Adj2 = Adj1;
    
    newtype Ctrl1 = ((Qubit, Qubit) => Unit is Ctl);
    
    newtype U1 = ((Qubit, Qubit, Qubit[]) => Unit is Adj + Ctl);
    
    newtype U2 = U1;
    
    newtype U3 = (Qubit => Unit is Adj + Ctl);
    
    
    operation BPlain1 (available : Int, q1 : Qubit, action : ((Qubit, Qubit) => Unit)) : Unit {
        
        
        borrowing (b = Qubit[2]) {
            Trace(available, b[0]);
            Trace(available, b[1]);
            action(b[0], b[1]);
        }
    }
    
    
    operation BPlain2 (available : Int, (q1 : Qubit, q2 : Qubit), action : Plain1) : Unit {
        
        
        borrowing (b = Qubit[2]) {
            Trace(available, b[0]);
            Trace(available, b[1]);
            action!(b[0], b[1]);
        }
    }
    
    
    operation BAdj1 (available : Int, (q1 : Qubit, q2 : Qubit, qs : Qubit[]), action : ((Qubit, Qubit) => Unit is Adj)) : Unit {
        
        body (...) {
            
            borrowing (b = Qubit[2]) {
                Trace(available, b[0]);
                Trace(available, b[1]);
                action(b[0], b[1]);
            }
        }
        
        adjoint invert;
    }
    
    
    operation BAdj2 (available : Int, qs : Qubit[], action : Adj1) : Unit {
        
        body (...) {
            
            borrowing (b = Qubit[2]) {
                Trace(available, b[0]);
                Trace(available, b[1]);
                action!(b[0], b[1]);
            }
        }
        
        adjoint invert;
    }
    
    
    operation BCtrl1 (available : Int, qs : Qs, action : ((Qubit, Qubit) => Unit is Ctl)) : Unit {
        
        body (...) {
            
            borrowing (b = Qubit[2]) {
                Trace(available, b[0]);
                Trace(available, b[1]);
                action(b[0], b[1]);
            }
        }
        
        controlled distribute;
    }
    
    
    operation BCtrl2 (available : Int, (qs1 : Qubit[], qs2 : Qs), action : Ctrl1) : Unit {
        
        body (...) {
            
            borrowing (b = Qubit[2]) {
                Trace(available, b[0]);
                Trace(available, b[1]);
                action!(b[0], b[1]);
            }
        }
        
        controlled distribute;
    }
    
    
    operation BU1 (available : Int, qs : Qubit[], action : ((Qubit, Qubit, Qubit[]) => Unit is Adj + Ctl)) : Unit {
        
        body (...) {
            
            borrowing (b = Qubit[2]) {
                Trace(available, b[0]);
                Trace(available, b[1]);
                action(b[0], b[1], qs);
            }
        }
        
        adjoint invert;
        controlled distribute;
        controlled adjoint distribute;
    }
    
    
    operation BGen<'T> (available : Int, arg : 'T, action : ((Qubit, Qubit, 'T) => Unit is Adj + Ctl)) : Unit {
        
        body (...) {
            
            borrowing (b = Qubit[2]) {
                Trace(available, b[0]);
                Trace(available, b[1]);
                action(b[0], b[1], arg);
            }
        }
        
        adjoint invert;
        controlled distribute;
        controlled adjoint distribute;
    }
    
    
    operation Action (q0 : Qubit, q1 : Qubit, array : Qubit[]) : Unit {
        
        body (...) {
            SWAP(q0, q1);
        }
        
        adjoint invert;
        controlled distribute;
        controlled adjoint distribute;
    }
    
    
    operation ActionGen<'T> (q0 : Qubit, q1 : Qubit, array : 'T) : Unit {
        
        body (...) {
            SWAP(q0, q1);
        }
        
        adjoint invert;
        controlled distribute;
        controlled adjoint distribute;
    }
    
    
    operation TestAllVariants<'T> (available : Int, args : 'T, action : ((Qubit, Qubit, 'T) => Unit is Adj + Ctl), B : ((Int, 'T, ((Qubit, Qubit, 'T) => Unit is Adj + Ctl)) => Unit is Adj + Ctl)) : Unit {
        
        
        using (ctrls = Qubit[2]) {
            B(available, args, action);
            Adjoint B(available, args, action);
            Controlled B(ctrls, (available, args, action));
            Adjoint Controlled B(ctrls, (available, args, action));
        }
    }
    
    
    operation BorrowingTest () : Unit {
        
        
        using (qubits = Qubit[5]) {
            let q0 = qubits[0];
            let q1 = qubits[1];
            let q2 = qubits[2];
            let q3 = qubits[3];
            let q4 = qubits[4];
            let e = new Qubit[0];
            let n = new Qubit[5];
            let a_0 = [q0];
            let a_2_2 = [q2, q2];
            let a_2_4 = qubits[2 .. 4];
            let q_e = Qs(e);
            let q_n = Qs(n);
            let q_1 = Qs([q1]);
            let q_2_2 = Qs(a_2_2);
            let q_2_4 = Qs(a_2_4);
            let t1_1_n = T1(q1, n[0]);
            let t1_1_2 = T1(q1, q2);
            let t2_1_n = T2(q1, n);
            let t2_1_e = T2(q1, e);
            let t2_1_a3 = T2(q1, a_2_4);
            let t3_e_e = T3(e, q_e);
            let t3_n_n = T3(n, q_n);
            let t3_all = T3([q1, q2], q_2_4);
            
            BPlain1(0, n[0], Action(_,_,qubits));                                               // 0, q5 & q6
                                                                                                    
            BPlain1(1, q1, Action(_,_,a_2_4));                                                  // 1, q0 & q6
            BPlain2(1, ((Q(q0))!, (Q(q0))!), Plain1(Action(_,_,a_2_4)));                        // 1, q1 & q6
                                                                                                    
            BPlain1(3, q0, Action(_,_,a_2_2));                                                  // 3, q1 & q3
            BPlain2(3, (q1, q2), Plain1(SWAP));                                                 // 3, q0 & q3
                                                                                                    
            BPlain1(4, q1, (Plain1(SWAP))!);                                                    // 4, q0 & q2
            BPlain2(5, (n[0], n[1]), Plain1(SWAP));                                             // 5, q0 & q1
                                                                                                    
            BAdj1(5, (n[0], n[1], e), (Adj1(SWAP))!);                                           // 5, q0 & q1
            (Adjoint BAdj1)(1, (q1, q2, q_2_4!), SWAP);                                         // 1, q0 & q6
            BAdj2(0, qubits, (Adj2(Adj1(SWAP)))!);                                              // 0, q5 & q6
            (Adjoint BAdj2)(1, (Qs([q0, n[0]]))!, (Adj2(Adj1(Action(_,_,a_2_4))))!);            // 1, q1 & q5
                
            BCtrl1(5, q_n, SWAP);                                                               // 5, q0 & q1
            (Controlled BCtrl1)([q1], (1, q_2_4, SWAP));                                        // 1, q0 & q5
            BCtrl2(0, (a_2_2, Qs(qubits)), Ctrl1(SWAP));                                        // 0, q5 & q6
            let ctrl = (Controlled (Ctrl1(Action(_,_,a_2_2)))!)([q4], (_,_));
            (Controlled BCtrl2)([q0], (1, ([q3], q_n), Ctrl1(ctrl)));                           // 1, q1 & q5
            (Controlled BCtrl2)(q_e!, (5, (n, q_e), Ctrl1(Action(_,_,n))));                     // 5, q0 & q1
                
            TestAllVariants(0, qubits, ActionGen<Qubit[]>, BGen<Qubit[]>);                                      // 0, q5 & q6 (q7 & q8 for controlled)
            TestAllVariants(2, (q0, q1, q4), ActionGen<(Qubit, Qubit, Qubit)>, BGen<(Qubit, Qubit, Qubit)>);    // 2, q2 & q3
            TestAllVariants(4, (Qs(q_1!))!, Action, BGen<Qubit[]>);                                             // 4, q0 & q2
            TestAllVariants(3, [q0, q1], Action(_,_,_), BU1);                                                   // 3, q2 & q3
            TestAllVariants(0, qubits, ActionGen<Qubit[]>(_,_,_), BGen<Qubit[]>);                               // 0, q5 & q6 (q7 & q8 for controlled)
            TestAllVariants(2, Qs([q0, q1, q4]), ActionGen<Qs>(_,_,_), BGen<Qs>);                               // 2, q2 & q3
            TestAllVariants(5, n, ActionGen<Qubit[]>(_,_,_), BGen<Qubit[]>);                                    // 5, q0 & q1
            TestAllVariants(5, n, Action(_,_,_), BGen<Qubit[]>);                                                // 5, q0 & q1
            TestAllVariants(4, a_0, Adjoint (ActionGen<Qubit[]>(_,_,_)), BGen<Qubit[]>);                        // 4, q1 & q2
                
            TestAllVariants(1, e, (Controlled Action([q1,q2,q3,q0], (_,_,_))), BGen<Qubit[]>);                  // 1, q4 & q5 (q7 for controlled)
            TestAllVariants(0, e, (Controlled (Adjoint ActionGen<Qubit[]>))(qubits, (_,_,_)), BGen<Qubit[]>);   // 0, q5 & q6 (q7 & q8 for controlled)
        }
    }
    
    
    operation SimpleRangeTest () : Unit {
        
        mutable ints = new Int[12];
        mutable results = new Result[12];
        mutable qubits = new Qubit[12];
        mutable qs = new Qs[12];
        mutable u1s = new U1[12];
        mutable state = new Complex[12];
        
        for (i in 10 .. -2 .. 4) {
            set ints = ints w/ i <- i;
            set results = results w/ i <- One;
            set qs = qs w/ i <- Qs(qubits);
            set u1s = u1s w/ i <- U1(Action);
            set state = state w/ i <- Complex(IntAsDouble(i), IntAsDouble(i + 1));
            Trace(ints[i]);
            Trace(results[i]);
            Trace(qubits[i]);
            Trace(qs[i]);
            Trace(u1s[i]);
            Trace(state[i]);
        }
    }
    
    
    operation SimpleDumpTest () : Unit {
        
        body (...) {
            
            using (qubits = Qubit[3]) {
                Message($"Starting test");
                DumpMachine($"dumptest-start.txt");
                ApplyToEachCA(H, qubits);
                DumpMachine($"dumptest-h.txt");
                DumpMachine($"");
                
                using (q2 = Qubit[2]) {
                    Assert([PauliZ, PauliZ], q2, Zero, $"Qubit should be in Zero state");
                    DumpRegister($"dumptest-former.txt", qubits);
                    DumpRegister($"dumptest-later.txt", q2);
                    DumpRegister($"dumptest-one.txt", [qubits[1]]);
                    DumpRegister($"dumptest-two.txt", [qubits[1], q2[1]]);
                    DumpRegister((), [qubits[1], q2[1]]);
                    DumpRegister("", [q2[1], qubits[1]]);
                    DumpMachine($"dumptest-all.txt");
                    ApplyToEachCA(Controlled X(qubits, _), q2);
                    DumpMachine($"dumptest-entangled.txt");
                    DumpRegister((), [qubits[1], q2[1]]);
                    DumpRegister($"dumptest-twoQubitsEntangled.txt", [qubits[0], q2[0]]);
                    DumpMachine();
                    ApplyToEachCA(Adjoint Controlled X(qubits, _), q2);
                }
                
                Adjoint ApplyToEachCA(H, qubits);
            }
            
            DumpMachine($"dumptest-end.txt");
            DumpMachine();
        }
    }
    
    operation LockedFileDumpTest () : Unit {
        using (qubits = Qubit[3]) {
            DumpMachine($"locked-file.txt");
            DumpRegister($"locked-file.txt", qubits[0..1]);

            // Make sure execution continues:
            Message("Done.");
        }
    }

    operation ZeroQubitsTest() : Unit
    {
        using (qubits = Qubit[0])
        {
            if (Length(qubits) == 0)
            {
                Trace("zero");
            }
        }
    }
}

// Using a different namespace, so tests can be auto-discovered.
namespace Microsoft.Quantum.Simulation.Simulators.Tests.Circuits {
    open Microsoft.Quantum.Simulation.Simulators.Tests.Circuits.Generics;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Math;

    operation QubitAllocationTest() : Unit {
        let n = 3;

        using (q = Qubit()) {
            Assert([PauliZ], [q], Zero, "Expecting Zero - a");
        }

        using (qs = Qubit[n]) {
            AssertEqual(n, Length(qs));
            Assert([PauliZ, PauliZ, PauliZ], qs, Zero, "Expecting Zero - b");
        }

        using ((q1, (q2t, (_, q3s, _, q4s))) = (Qubit(), ((Qubit(), Qubit[2]), (Qubit(), Qubit[n], Qubit[n-1], Qubit[4])))) {
            let (a, b) = q2t;

            AssertEqual(2, Length(b));
            AssertEqual(n, Length(q3s));
            AssertEqual(4, Length(q4s));

            Assert([PauliZ, PauliZ], [q1, a], Zero, "Expecting Zero - c");
            Assert([PauliZ, PauliZ], b, Zero, "Expecting Zero - d");
            Assert([PauliZ, PauliZ, PauliZ], q3s, Zero, "Expecting Zero - d");
            Assert([PauliZ, PauliZ, PauliZ, PauliZ], q4s, Zero, "Expecting Zero - e");
            
        }
            
        using (qt = (Qubit(), (Qubit[1], Qubit[2]))) {
            let (qt1, (qt2a, qt2b)) = qt;

            Assert([PauliZ], [qt1], Zero, "Expecting Zero - f");
            Assert([PauliZ], qt2a, Zero, "Expecting Zero - g");
            Assert([PauliZ, PauliZ], qt2b, Zero, "Expecting Zero - h");
        }
    }

    
    operation ExtendedForTest() : Unit
    {
        mutable n = 0;

        using (qs = Qubit[3]) {

            for(q in qs) {
                Assert([PauliZ], [q], Zero, "Expecting Zero - a");
                set n = n + 1;
            }

            AssertEqual(3, n);
        }
    }

    function WhileLoopTest() : Unit
    {
		mutable ctr = 0;
        while (ctr < 10) {
			set ctr += 1;
		}
		AssertEqual(ctr, 10);
    }

    newtype WrappedInt = (Int);

    operation InterpolatedStringTest() : Unit
    {
        let a = 5;
        let b = "Hello";
        let c = 1..2..3;
        let d = WrappedInt(6);
        let s = $"{b}, world! {a}+{RangeStart(c)}={d!}";
        AssertEqual("Hello, world! 5+1=6", s);
    }

    operation RandomOperationTest() : Unit
    {
        let a = Random([1.0, 0.0]);
        AssertEqual(0, a);

        let b = Random([0.0,0.1]);
        AssertEqual(1, b);
    }

    function BigIntTest() : Unit
    {
        let a = 2L;
        let b = 32L;
        AssertEqual(b, a ^ 5);
        AssertEqual(0L, a &&& b);
        AssertEqual(34L, a + b);
        let arr = [true, true, true, false, true];    // Not an even number of bytes
        AssertEqual(23L, BoolArrayAsBigInt(arr));
        let arr2 = [true, true,  true,  false, true,  false, false, false,
                    true, false, false, false, false, false, false, false];    // Exactly 2 bytes
        AssertEqual(279L, BoolArrayAsBigInt(arr2));
        AssertEqual(37L, BoolArrayAsBigInt(BigIntAsBoolArray(37L)));
        let (div, rem) = DivRemL(16L, 5L);
        AssertEqual(3L, div);
        AssertEqual(1L, rem);
        AssertEqual(7L, MaxL(7L, 5L));
        AssertEqual(5L, MinL(7L, 5L));
        AssertEqual(1L, ModPowL(3L, 100L, 2L));
    }
    
    operation RangePropsTest() : Unit
    {
        let range = 1..2..10;
        let actual = RangeStart(range) + RangeEnd(range) + RangeStep(range);
        AssertEqual(13, actual);
    }

    function ArraySlicingTest() : Unit
    {
		let arr = [1,2,3,4,5,6];
		let slice1 = arr[3...];
		AssertEqual(slice1, [4,5,6]);
		let slice2 = arr [0 .. 2 ... ];
		AssertEqual(slice2, [1,3,5]);
		let slice3 = arr[...2];
		AssertEqual(slice3, [1,2,3]);
		let slice4 = arr[...2..3];
		AssertEqual(slice4, [1,3]);
		let slice5 = arr[...2...];
		AssertEqual(slice5, [1,3,5]);
		let slice6 = arr[...];
		AssertEqual(slice6, arr);
		let slice7 = arr [4 .. -2 ... ];
		AssertEqual(slice7, [5,3,1]);
		let slice8 = arr[ ... 0-1 .. 3];
		AssertEqual(slice8, [6,5,4]);
		let slice9 = arr[...4-5...];
		AssertEqual(slice9, [6,5,4,3,2,1]);
    }

    operation ReturnFromWithinUsing() : Int {
        using (q = Qubit()){
            return 1; 
        }
    }

    operation ReturnFromWithinBorrowing() : Int {
        borrowing (q = Qubit()){
            return 1; 
        }
    }

    operation ReturnTest() : Unit {
        let _ = ReturnFromWithinUsing(); 
        let _ = ReturnFromWithinBorrowing(); 
    }

    operation VariablesScopeTest() : Unit
    {
        mutable a = 0;

        using (qubits = Qubit[5])
        {
            for(q in qubits) {
                set a = a + 1;
            }
            AssertEqual(5, a);

            for(q in 0 .. 3) {
                set a = a + 1;
            }
            AssertEqual(9, a);
        }
        
        borrowing (qubits = Qubit[2])
        {
            for(q in qubits) {
                set a = a + 1;
            }
            AssertEqual(11, a);

            for(q in 0 .. 0) {
                set a = a + 1;
            }
            AssertEqual(12, a);
        }
    }

    // Returning the value returned by a function
    // that returns Unit...
    // Not totally sure if this should be allowed, but it works as of v0.3
    function Bar() : Unit { }
    
    function Foo<'T>(a: 'T) : Unit  {
        return Bar();
    }

    operation Bug2186Test() : Unit {
        return Foo(3);
    }

    operation UsingQubitCheck () : Unit 
    {
        using (q = Qubit())
        {
            X(q);
            // Should raise an exception
        }
    }

    operation ReleaseMeasuredQubitCheck () : Unit 
    {
        using (q = Qubit())
        {
            X(q);
            let r = M(q);
            // Should not raise an exception
        }
    }

    operation ReleaseMeasureMultipleQubitCheck() : Unit {
        using (qs = Qubit[2]) {
            ApplyToEach(H, qs);
            let r = Measure([PauliZ, PauliZ], qs);
            // Should raise an exception
        }
    }

    operation BorrowingQubitCheck () : Unit
    {
        using (q = Qubit())
        {
            QubitBorrower();
        }
    }

    operation QubitBorrower() : Unit
    {
        borrowing (q = Qubit())
        {
            X(q);
            // Should raise an exception
        }
    }

    operation DumpPhaseTest() : Unit
    {
        using (qs = Qubit[5]) {
            H(qs[0]);
            Controlled X(qs[0..0], qs[1]);
            T(qs[1]);
            DumpRegister($"dumptest-entangled-and-phased.txt", qs[0..1]);
            ResetAll(qs);

            for(q in qs) { H(q); }

            R1Frac(1, 3, qs[0]);
            R1Frac(1, 2, qs[1]);
            R1Frac(1, 1, qs[2]);
            R1Frac(1, 0, qs[3]);

            DumpRegister($"dumptest-phase.txt", qs);

            ResetAll(qs);
        }
    }

    operation PiTest() : Unit {
        let pi = PI();

        AssertEqual(true, (pi > 3.14 and pi < 3.15));
    }

    internal function EmptyInternalFunction() : Unit { }

    internal operation EmptyInternalOperation() : Unit { }

    internal newtype InternalType = Int;

    internal operation MakeInternalType() : InternalType {
        return InternalType(5);
    }

    // This is a public operation that uses an internal type inside to test the access modifiers of the generated
    // operation properties.
    operation InternalCallablesTest() : Unit {
        EmptyInternalFunction();
        EmptyInternalOperation();
        let x = InternalType(3);
        let y = MakeInternalType();
        AssertEqual(15, x! * y!);
    }
}

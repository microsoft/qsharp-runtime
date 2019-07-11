// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.Simulators.Tests.Circuits
{
    open Microsoft.Quantum.Intrinsic;

    newtype P1 = (Int, Int);
    newtype P2 = ((Int, Int), Int);

    function TakesUdtPartial<'T, 'U> (build : ('T -> 'U), remainingArgs : 'T) : 'U {
        return build(remainingArgs);
    } 

    operation PassingUDTConstructorTest() : Unit
    {
        let ((a1, b1), c1) = (TakesUdtPartial(P2, ((1,2),3)))!;
        AssertEqual(a1, 1);
        AssertEqual(b1, 2);
        AssertEqual(c1, 3);

        let partial = P2((_,2), _);
        let full = TakesUdtPartial(partial, (3,1));        
        let ((a2, b2), c2) = full!;
        AssertEqual(a2, 3);
        AssertEqual(b2, 2);
        AssertEqual(c2, 1);
    }

    operation PartialNestedUDTTest() : Unit
    {
        let partial = P2((_,2), _);
        let full = partial(3, 1);
        
        let ((a, b), c) = full!;
        AssertEqual(a, 3);
        AssertEqual(b, 2);
        AssertEqual(c, 1);
    }

    operation PartialUDTTest() : Unit
    {
        let partial = P1(2, _);
        let full = partial(3);
        
        let (a, b) = full!;
        AssertEqual(5, a+b);
        
        let full2 = partial(10);
        let (x, y) = full2!;
        AssertEqual(12, x + y);
    }

    operation IndirectPartialUDTTest() : Unit
    {
        let pa1 = P2((_,2), _);
        let pa2 = pa1(1,_);
        let ((a1, b1), c1) = (pa2(3))!;
        AssertEqual(a1, 1);
        AssertEqual(b1, 2);
        AssertEqual(c1, 3);

        let full = TakesUdtPartial(pa1(3,_), 1);
        let ((a2, b2), c2) = full!;
        AssertEqual(a2, 3);
        AssertEqual(b2, 2);
        AssertEqual(c2, 1);
    }

    function returnUdtConstructor () : (((Int, Int), Int) -> P2) {
        return P2;
    }

    function returnPartialUdtConstructor () : ((Int, Int) -> P2) {
        return P2((3,_),_);
    }

    function CallReturnedUdtConstructorTest () : Unit 
    {
        let udt1 = (returnUdtConstructor())((1,2),3);
        let ((a1,b1),c1) = udt1!;
        AssertEqual(a1, 1);
        AssertEqual(b1, 2);
        AssertEqual(c1, 3);

        let udt2 = (returnPartialUdtConstructor())(2,1);
        let ((a2,b2),c2) = udt2!;
        AssertEqual(a2, 3);
        AssertEqual(b2, 2);
        AssertEqual(c2, 1);
    }

    function ConstantArray<'T>(size : Int, item : 'T) : 'T[] {
        mutable arr = new 'T[size];
        for (i in 0 .. size-1) {
            set arr w/= i <- item;
        }
        return arr;
    }

    function UdtConstructorArrayTest () : Unit {
        let arr = ConstantArray(5, P2);
        for (ctor in arr) {
            let ((a,b),c) = (ctor((1, 2), 3))!;
            AssertEqual(a, 1);
            AssertEqual(b, 2);
            AssertEqual(c, 3);
        }
    }
}


// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.Simulators.Tests.Circuits {
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Intrinsic;

    operation MapF<'T, 'U>(mapper : ('T -> 'U), source : 'T[]) : 'U[] {
        mutable result = new 'U[Length(source)];
        for (i in 0 .. Length(source) - 1) {
            let m = mapper(source[i]);
            set result = result w/ i <- m;
        }
        
        return result;
    }

    operation LengthTest() : Unit {
        let a1 = [One, Zero];
        let a2 = [Zero, Zero, Zero];

        AssertEqual(2, Length(a1));
        AssertEqual(3, Length(a2));

        let values = MapF(Length<Result>, [a1, a2]);
        AssertEqual(2, values[0]);
        AssertEqual(3, values[1]);
    }

    @Test("QuantumSimulator")
    function CreateArrayWithPositiveSize() : Unit {
        let xs = [true, size = 3];
        AssertEqual([true, true, true], xs);
    }

    @Test("QuantumSimulator")
    function CreateArrayWithZeroSize() : Unit {
        let xs = [true, size = 0];
        AssertEqual(0, Length(xs));
    }

    function CreateArrayWithNegativeSize() : Bool[] {
        return [true, size = -1];
    }

    @Test("QuantumSimulator")
    function CreateArrayWithSizeExpression() : Unit {
        let n = 2;
        let xs = [7, size = n + 1];
        AssertEqual([7, 7, 7], xs);
    }

    @Test("QuantumSimulator")
    function CreateArrayWithValueExpression() : Unit {
        let x = "foo";
        let xs = [x + "bar", size = 3];
        AssertEqual(["foobar", "foobar", "foobar"], xs);
    }

    @Test("QuantumSimulator")
    function SizedArrayShouldIncrementArrayItemRefCount() : Unit {
        mutable item = [1];
        let items = [item, size = 2];
        set item w/= 0 <- 2;

        AssertEqual([2], item);
        AssertEqual([[1], [1]], items);
    }

    @Test("QuantumSimulator")
    function ArrayOfArraysShouldCopyOnUpdate() : Unit {
        mutable items = [[1], size = 2];
        set items w/= 0 <- items[0] w/ 0 <- 2;

        AssertEqual([[2], [1]], items);
    }
}

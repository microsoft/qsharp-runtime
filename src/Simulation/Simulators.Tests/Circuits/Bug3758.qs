// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace Bug3758 {
    open Microsoft.Quantum.Intrinsic;

    function Reverse<'T> (array : 'T[]) : 'T[] {
        let nElements = Length(array);
        return array[nElements-1..-1..0];
    }

    operation ApplyWithInputTransformation<'T, 'U>(fn : ('U -> 'T), op : ('T => Unit), input : 'U) : Unit {
        op(fn(input));
    }

    function TransformedOperation<'T, 'U>(fn : ('U -> 'T), op : ('T => Unit)) : ('U => Unit) {
        return ApplyWithInputTransformation(fn, op, _);
    }

    
    /// # Summary
    /// An example operation used for testing input transformations.
    operation TransformationReferenceForward(register : Qubit[]) : Unit is Adj + Ctl {
        X(register[0]);
        H(register[1]);
        X(register[2]);
    }

    /// # Summary
    /// An example operation used for testing input transformations.
    operation TransformationReferenceReverse(register : Qubit[]) : Unit is Adj + Ctl {
        X(register[2]);
        H(register[1]);
        X(register[0]);
    }
}



namespace Microsoft.Quantum.Simulation.Simulators.Tests.Circuits {
    open Bug3758;
    open Microsoft.Quantum.Diagnostics;

    operation TransformedOperationTest() : Unit {
        AssertOperationsEqualReferenced(3,
            TransformedOperation(Reverse<Qubit>, TransformationReferenceReverse),
            TransformationReferenceForward
        );
    }
}

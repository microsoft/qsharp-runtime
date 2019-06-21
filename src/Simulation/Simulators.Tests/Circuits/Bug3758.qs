// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Bug3758
{
    open Microsoft.Quantum.Primitive;

    function Reverse<'T> (array : 'T[]) : 'T[]
    {
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
    operation TransformationReferenceForward(register : Qubit[]) : Unit {
        body (...) {
            X(register[0]);
            H(register[1]);
            X(register[2]);
        }
        adjoint auto;
        controlled auto;
        controlled adjoint auto;
    }

    /// # Summary
    /// An example operation used for testing input transformations.
    operation TransformationReferenceReverse(register : Qubit[]) : Unit {
        body (...) {
            X(register[2]);
            H(register[1]);
            X(register[0]);
        }
        adjoint auto;
        controlled auto;
        controlled adjoint auto;
    }
}



namespace Microsoft.Quantum.Simulation.Simulators.Tests.Circuits
{
    open Bug3758;
    open Microsoft.Quantum.Extensions.Testing;

    operation TransformedOperationTest() : Unit {
        AssertOperationsEqualReferenced(
            TransformedOperation(Reverse<Qubit>, TransformationReferenceReverse),
            TransformationReferenceForward,
            3
        );
    }
}

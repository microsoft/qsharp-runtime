// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Arrays {
    open Microsoft.Quantum.Diagnostics;

    /// # Summary
    /// Checks that empty arrays are indeed empty.
    @Test("QuantumSimulator")
    @Test("ToffoliSimulator")
    @Test("Microsoft.Quantum.Experimental.OpenSystemsSimulator")
    function EmptyArraysAreEmpty() : Unit {
        Fact(
            Length(EmptyArray<Int>()) == 0,
            "Empty array of type Int[] was not actually empty."
        );
        Fact(
            Length(EmptyArray<(Double, Pauli[])>()) == 0,
            "Empty array of type (Double, Pauli[])[] was not actually empty."
        );
    }

}

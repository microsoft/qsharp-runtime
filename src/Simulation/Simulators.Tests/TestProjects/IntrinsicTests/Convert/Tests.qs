// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Tests {
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Diagnostics;

    @Test("QuantumSimulator")
    @Test("SparseSimulator")
    function DoubleAsStringIsCorrect() : Unit {
        EqualityFactS(DoubleAsString(12.345), "12.345", "DoubleAsString was incorrect.");
    }

    @Test("QuantumSimulator")
    @Test("SparseSimulator")
    function IntAsStringIsCorrect() : Unit {
        EqualityFactS(IntAsString(12345), "12345", "IntAsString was incorrect.");
    }

}

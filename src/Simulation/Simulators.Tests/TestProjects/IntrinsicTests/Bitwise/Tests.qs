// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Tests {
    open Microsoft.Quantum.Bitwise;
    open Microsoft.Quantum.Diagnostics;

    @Test("QuantumSimulator")
    function XorIsCorrect() : Unit {
        EqualityFactI(199, Xor(248, 63), "Xor was incorrect.");
    }

    @Test("QuantumSimulator")
    function AndIsCorrect() : Unit {
        EqualityFactI(56, And(248, 63), "And was incorrect.");
    }

    @Test("QuantumSimulator")
    function OrIsCorrect() : Unit {
        EqualityFactI(255, Or(248, 63), "Or was incorrect.");
    }

    @Test("QuantumSimulator")
    function NotIsCorrect() : Unit {
        EqualityFactI(-249, Not(248), "Not was incorrect.");
    }

    @Test("QuantumSimulator")
    function XBitsIsCorrect() : Unit {
        // We expect this to be 3, 3 = 0011₂. In little endian representation,
        // we start with the 1s digit, so we get that 3 is what we get from
        // [1, 1, 0, 0]
        EqualityFactI(XBits([PauliX, PauliY, PauliZ, PauliI]), 3, "XBits was incorrect.");
    }

    @Test("QuantumSimulator")
    function ZBitsIsCorrect() : Unit {
        EqualityFactI(ZBits([PauliX, PauliY, PauliZ, PauliI]), 6, "XBits was incorrect.");
    }
}

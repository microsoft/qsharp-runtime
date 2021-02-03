// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Tests {
    open Microsoft.Quantum.Math;

    @Test("QuantumSimulator")
    function AbsDIsCorrect() : Unit {
        EqualityFactD(AbsD(-1.23), 1.23, "AbsD was incorrect for negative numbers.");
        EqualityFactD(AbsD(1.23), 1.23, "AbsD was incorrect for positive numbers.");
        EqualityFactD(AbsD(0.0), 0.0, "AbsD was incorrect for zero.");
    }

    @Test("QuantumSimulator")
    function AbsIIsCorrect() : Unit {
        EqualityFactI(AbsI(-123), 123, "AbsI was incorrect for negative numbers.");
        EqualityFactI(AbsI(123), 123, "AbsI was incorrect for positive numbers.");
        EqualityFactI(AbsI(0), 0, "AbsI was incorrect for zero.");
    }

    @Test("QuantumSimulator")
    function AbsLIsCorrect() : Unit {
        EqualityFactI(AbsL(-123L), 123L, "AbsL was incorrect for negative numbers.");
        EqualityFactI(AbsL(123L), 123L, "AbsL was incorrect for positive numbers.");
        EqualityFactI(AbsL(0L), 0L, "AbsL was incorrect for zero.");
    }

    @Test("QuantumSimulator")
    function Log10IsCorrect() : Unit {
        EqualityWithinToleranceFact(Log10(0.456), -0.341035157335565, "Log10(0.456) was incorrect.");
        EqualityWithinToleranceFact(Log10(1.0), 0.0, "Log10(1.0) was incorrect.");
        EqualityWithinToleranceFact(Log10(1.23), 0.0899051114393979, "Log10(1.23) was incorrect.");
        EqualityWithinToleranceFact(Log10(10.0), 1.0, "Log10(10.0) was incorrect.");
        EqualityWithinToleranceFact(Log10(100.0), 2.0, "Log10(100.0) was incorrect.");
        EqualityWithinToleranceFact(Log10(123.456), 2.09151220162777, "Log10(123.456) was incorrect.");
    }

    @Test("QuantumSimulator")
    function MaxDIsCorrect() : Unit {
        EqualityFactD(MaxD(-1.0, 2.0), 2.0, "MaxD was incorrect.");
    }

    @Test("QuantumSimulator")
    function MaxIIsCorrect() : Unit {
        EqualityFactD(MaxI(-1, 2), 2, "MaxI was incorrect.");
    }

}

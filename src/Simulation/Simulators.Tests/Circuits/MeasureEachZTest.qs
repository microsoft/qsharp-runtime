// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.Simulators.Tests.Circuits {
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Measurement;

    internal function EqualityFactResultArray(actual : Result[], expected : Result[], message : String) : Unit {
        if Length(actual) != Length(expected) {
            fail $"Arrays presented to EqualityFactResultArray must be of the same length. Length(actual) = {Length(actual)}, Length(expected) = {Length(expected)}";
        }
        for i in 0..(Length(actual) - 1) {
            EqualityFactR(actual[i], expected[i], message);
        }
    }

    operation MeasureEachZTest() : Unit {
        use qs = Qubit[4];
        mutable expected = [Zero, size = Length(qs)];
        EqualityFactResultArray(MeasureEachZ(qs), expected, "Qubits should start in zero state");
        for i in 0..(Length(qs) - 1) {
            X(qs[i]);
            set expected w/= i <- One;
            EqualityFactResultArray(MeasureEachZ(qs), expected, $"Qubits state should be |{i + 1}⟩");
        }
    }

}
// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Testing.QIR  {

    open Microsoft.Quantum.Diagnostics;

    @EntryPoint()
    operation AssertMeasurementTest() : Unit {
        use qubit = Qubit();
        // Test that all the calls are resolved (linker is happy):
        AssertMeasurement([PauliZ], [qubit], Zero, "Newly allocated qubit must be in the |0> state.");
        AssertMeasurementProbability ([PauliZ], [qubit], Zero, 1.0, "Newly allocated qubit must be in the |0> state.", 1e-10);
    }
} // namespace Microsoft.Quantum.Testing.QIR

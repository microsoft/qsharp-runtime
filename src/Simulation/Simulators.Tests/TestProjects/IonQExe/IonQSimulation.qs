// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.


namespace Microsoft.Quantum.Simulation.Testing.IonQ {
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Simulation.Testing.IonQ.MeasurementSupportTests;

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    @Test("SparseSimulator")
    operation MeasureInMiddleTest() : Unit {
        MeasureInMiddle();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    @Test("SparseSimulator")
    operation QubitAfterMeasurementTest() : Unit {
        QubitAfterMeasurement();
    }
}

// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.


namespace Microsoft.Quantum.Simulation.Testing.IonQ {
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Simulation.Testing.IonQ.MeasurementSupportTests;

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    @Test("Microsoft.Quantum.Simulation.Simulators.SparseSimulator")
    operation MeasureInMiddleTest() : Unit {
        MeasureInMiddle();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    @Test("Microsoft.Quantum.Simulation.Simulators.SparseSimulator")
    operation QubitAfterMeasurementTest() : Unit {
        QubitAfterMeasurement();
    }
}

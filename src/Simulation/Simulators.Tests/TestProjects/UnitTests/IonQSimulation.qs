// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.


namespace Microsoft.Quantum.Simulation.Testing.IonQ {
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Simulation.Testing.IonQ.MeasurementSupportTests;

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    operation MeasureInMiddleTest() : Unit {
        MeasureInMiddle();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    operation QubitAfterMeasurementTest() : Unit {
        QubitAfterMeasurement();
    }
}

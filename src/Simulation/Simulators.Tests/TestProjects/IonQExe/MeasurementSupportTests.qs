// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.


namespace Microsoft.Quantum.Simulation.Testing.IonQ.MeasurementSupportTests {

    open Microsoft.Quantum.Intrinsic;

    operation MeasureInMiddle() : Unit {
        using (qs = Qubit[2]) {
            H(qs[0]);
            let r1 = M(qs[0]);
            H(qs[1]);
            let r2 = M(qs[1]);
            Reset(qs[0]);
            Reset(qs[1]);
        }
    }

    operation QubitAfterMeasurement() : Unit {
        using (q = Qubit()) {
            H(q);
            let r1 = M(q);
            H(q);
            let r2 = M(q);
            Reset(q);
        }
    }

}
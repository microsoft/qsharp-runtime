// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.


namespace Microsoft.Quantum.Simulation.QCTraceSimulatorRuntime.Tests {
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Diagnostics;

    internal function Fact(condition : Bool, message : String) : Unit {
        if (not condition) {
            fail message;
        }
    }

    @Test("ResourcesEstimator")
    /// # Summary
    /// Checks for regression against microsoft/qsharp-runtime#256.
    operation CheckRandomInCorrectRange() : Unit {
        for (idxTrial in 0..99) {
            let sample = Random([1.0, 2.0, 2.0]);

            Fact(0 <= sample and sample <= 2, $"sample was {sample}, not in range [0, 2]");
        }
    }
}

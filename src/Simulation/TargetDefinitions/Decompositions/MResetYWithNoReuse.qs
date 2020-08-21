// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Measurement {
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Diagnostics;

    /// # Summary
    /// Measures a single qubit in the Y basis,
    /// and resets it to a fixed initial state
    /// following the measurement.
    ///
    /// # Description
    /// Performs a single-qubit measurement in the $Y$-basis,
    /// and ensures that the qubit is returned to $\ket{0}$
    /// following the measurement.
    ///
    /// # Input
    /// ## target
    /// A single qubit to be measured.
    ///
    /// # Output
    /// The result of measuring `target` in the Pauli $Y$ basis.
    @EnableTestingViaName("Test.TargetDefinitions.MResetY")
    operation MResetY (target : Qubit) : Result {
        return Measure([PauliY], [target]);
    }
}
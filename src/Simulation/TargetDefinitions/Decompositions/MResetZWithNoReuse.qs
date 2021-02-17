// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Measurement {
    open Microsoft.Quantum.Intrinsic;

    /// # Summary
    /// Measures a single qubit in the Z basis,
    /// and resets it to a fixed initial state
    /// following the measurement.
    ///
    /// # Description
    /// Performs a single-qubit measurement in the $Z$-basis,
    /// and ensures that the qubit is returned to $\ket{0}$
    /// following the measurement.
    ///
    /// # Input
    /// ## target
    /// A single qubit to be measured.
    ///
    /// # Output
    /// The result of measuring `target` in the Pauli $Z$ basis.
    operation MResetZ (target : Qubit) : Result {
        // Because the qubit cannot be reused after measurement, no actual
        // reset is required.
        return M(target);
    }
}
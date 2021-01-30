// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Measurement {
    open Microsoft.Quantum.Intrinsic;

    /// # Summary
    /// Measures a single qubit in the X basis,
    /// and resets it to a fixed initial state
    /// following the measurement.
    ///
    /// # Description
    /// Performs a single-qubit measurement in the $X$-basis,
    /// and ensures that the qubit is returned to $\ket{0}$
    /// following the measurement.
    ///
    /// # Input
    /// ## target
    /// A single qubit to be measured.
    ///
    /// # Output
    /// The result of measuring `target` in the Pauli $X$ basis.
    operation MResetX (target : Qubit) : Result {
        // Because the qubit cannot be reused after measurement, no actual
        // reset is required.
        return Measure([PauliX], [target]);
    }
}
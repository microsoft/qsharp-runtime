// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Measurement {
    open Microsoft.Quantum.Intrinsic;

    /// # Summary
    /// Measures each qubit in a given array in the standard basis.
    /// # Input
    /// ## targets
    /// An array of qubits to be measured.
    /// # Output
    /// An array of measurement results.
    ///
    /// # Remarks
    /// This operation does not reset the measured qubits to the |0⟩ state, 
    /// leaving them in the state that corresponds to the measurement results.
    operation MeasureEachZ (targets : Qubit[]) : Result[] {
        body intrinsic;
    }

}

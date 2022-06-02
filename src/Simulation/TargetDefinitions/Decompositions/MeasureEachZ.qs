// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Measurement {
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Targeting;

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
    @RequiresCapability(
        "BasicExecution",
        "MeasureEachZ is replaced by a supported implementation on all execution targets."
    )
    operation MeasureEachZ (targets : Qubit[]) : Result[] {
        let len = Length(targets);
        mutable results = [Zero, size = len];
        for i in 0..(len - 1) {
            set results w/= i <- M(targets[i]);
        }
        return results;
    }

}

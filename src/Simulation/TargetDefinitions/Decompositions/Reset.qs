// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Intrinsic {
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Targeting;

    /// # Summary
    /// Given a single qubit, measures it and ensures it is in the |0⟩ state
    /// such that it can be safely released.
    ///
    /// # Input
    /// ## qubit
    /// The qubit whose state is to be reset to $\ket{0}$.
    @RequiresCapability(
        "BasicQuantumFunctionality",
        "Reset is replaced by a supported implementation on all execution targets."
    )
    operation Reset (qubit : Qubit) : Unit {
        if (M(qubit) == One) {
            X(qubit);
        }
    }
}
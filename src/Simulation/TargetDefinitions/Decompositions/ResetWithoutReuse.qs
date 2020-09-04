// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Intrinsic {
    open Microsoft.Quantum.Diagnostics;

    /// # Summary
    /// Given a single qubit, measures it and ensures it is in the |0⟩ state
    /// such that it can be safely released.
    ///
    /// # Input
    /// ## qubit
    /// The qubit whose state is to be reset to $\ket{0}$.
    @EnableTestingViaName("Test.TargetDefinitions.Reset")
    operation Reset (target : Qubit) : Unit {
        // This platform doesn't support use of a qubit after measurement, so 
        // `Reset` is really just marking the qubit as measured.
        let r = M(target);
    }
}
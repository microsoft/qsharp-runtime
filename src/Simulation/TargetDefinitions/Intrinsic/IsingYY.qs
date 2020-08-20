// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Intrinsic {
    open Microsoft.Quantum.Diagnostics;

    /// # Summary
    /// Applies the Ising $YY$ gate.
    ///
    /// TODO - describe YY gate.
    ///
    /// # Input
    /// ## theta
    /// The angle about which the qubits are rotated.
    /// ## qubit0
    /// The first qubit input to the gate.
    /// ## qubit1
    /// The second qubit input to the gate.
    @EnableTestingViaName("Test.TargetDefinitions.IsingYY")
    operation IsingYY (theta : Double, qubit0 : Qubit, qubit1 : Qubit) : Unit is Ctl {
        body intrinsic;
    }
}
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Intrinsic {
    open Microsoft.Quantum.Diagnostics;

    /// # Summary
    /// Applies the Ising $XX$ gate.
    ///
    /// TODO - describe XX gate.
    ///
    /// # Input
    /// ## theta
    /// The angle about which the qubits are rotated.
    /// ## qubit0
    /// The first qubit input to the gate.
    /// ## qubit1
    /// The second qubit input to the gate.
    @EnableTestingViaName("Test.TargetDefinitions.IsingXX")
    operation IsingXX (theta : Double, qubit0 : Qubit, qubit1 : Qubit) : Unit is Ctl {
        body intrinsic;
    }
}
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Intrinsic {

    /// # Summary
    /// Applies the two qubit Ising $ZZ$ rotation gate.
    ///
    /// # Description
    /// \begin{align}
    ///     ZZ(\theta) \mathrel{:=}
    ///     \begin{bmatrix}
    ///         e^{-i \theta / 2} & 0 & 0 & 0 \\\\
    ///         0 & e^{-i \theta / 2} & 0 & 0 \\\\
    ///         0 & 0 & e^{-i \theta / 2} & 0 \\\\
    ///         0 & 0 & 0 & e^{i \theta / 2}
    ///     \end{bmatrix}.
    /// \end{align}
    ///
    /// # Input
    /// ## theta
    /// The angle about which the qubits are rotated.
    /// ## qubit0
    /// The first qubit input to the gate.
    /// ## qubit1
    /// The second qubit input to the gate.
    internal operation IsingZZ (theta : Double, qubit0 : Qubit, qubit1 : Qubit) : Unit is Adj + Ctl {
        body intrinsic;
    }
}
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Intrinsic {

    /// # Summary
    /// Applies the Pauli $Z$ gate.
    ///
    /// # Description
    /// \begin{align}
    ///     \sigma_z \mathrel{:=}
    ///     \begin{bmatrix}
    ///         1 & 0 \\\\
    ///         0 & -1
    ///     \end{bmatrix}.
    /// \end{align}
    ///
    /// # Input
    /// ## qubit
    /// Qubit to which the gate should be applied.
    operation Z (qubit : Qubit) : Unit is Adj + Ctl {
        body intrinsic;
        adjoint self;
    }
}
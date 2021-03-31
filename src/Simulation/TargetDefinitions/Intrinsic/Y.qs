// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Intrinsic {

    /// # Summary
    /// Applies the Pauli $Y$ gate.
    ///
    /// # Description
    /// \begin{align}
    ///     \sigma_y \mathrel{:=}
    ///     \begin{bmatrix}
    ///         0 & -i \\\\
    ///         i & 0
    ///     \end{bmatrix}.
    /// \end{align}
    ///
    /// # Input
    /// ## qubit
    /// Qubit to which the gate should be applied.
    operation Y (qubit : Qubit) : Unit is Adj + Ctl {
        body intrinsic;
        adjoint self;
    }
}
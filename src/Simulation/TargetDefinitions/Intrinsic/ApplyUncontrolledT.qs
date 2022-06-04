// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Intrinsic {
    open Microsoft.Quantum.Targeting;

    /// # Summary
    /// Applies the π/8 gate to a single qubit. Note that the Controlled functor is
    /// not supported.
    ///
    /// # Description
    /// \begin{align}
    ///     T \mathrel{:=}
    ///     \begin{bmatrix}
    ///         1 & 0 \\\\
    ///         0 & e^{i \pi / 4}
    ///     \end{bmatrix}.
    /// \end{align}
    ///
    /// # Input
    /// ## qubit
    /// Qubit to which the gate should be applied.
    @TargetInstruction("t__body")
    internal operation ApplyUncontrolledT (qubit : Qubit) : Unit {
        body intrinsic;
    }
}
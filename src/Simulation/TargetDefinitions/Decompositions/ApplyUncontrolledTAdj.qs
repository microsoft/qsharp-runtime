// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Intrinsic {
    open Microsoft.Quantum.Math;

    /// # Summary
    /// Applies the -π/8 gate to a single qubit. Note that the Controlled functor is
    /// not supported.
    ///
    /// # Description
    /// \begin{align}
    ///     TAdj \mathrel{:=}
    ///     \begin{bmatrix}
    ///         1 & 0 \\\\
    ///         0 & e^{i -\pi / 4}
    ///     \end{bmatrix}.
    /// \end{align}
    ///
    /// # Input
    /// ## qubit
    /// Qubit to which the gate should be applied.
    internal operation ApplyUncontrolledTAdj (qubit : Qubit) : Unit {
        ApplyUncontrolledRz(-PI() / 4.0, qubit);
    }
}
// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Intrinsic {
    open Microsoft.Quantum.Math;

    /// # Summary
    /// Applies the -π/4 phase gate to a single qubit. Note that the Controlled functor
    /// is not supported.
    ///
    /// # Description
    /// \begin{align}
    ///     SAdj \mathrel{:=}
    ///     \begin{bmatrix}
    ///         1 & 0 \\\\
    ///         0 & -i
    ///     \end{bmatrix}.
    /// \end{align}
    ///
    /// # Input
    /// ## qubit
    /// Qubit to which the gate should be applied.
    internal operation ApplyUncontrolledSAdj (qubit : Qubit) : Unit {
         ApplyUncontrolledRz(-PI() / 2.0, qubit);
    }
}
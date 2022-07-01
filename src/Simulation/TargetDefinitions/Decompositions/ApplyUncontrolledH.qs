// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Intrinsic {
    open Microsoft.Quantum.Math;

    /// # Summary
    /// Applies the Hadamard transformation to a single qubit. Note that the Controlled 
    /// functor is not supported.
    ///
    /// # Description
    /// \begin{align}
    ///     H \mathrel{:=}
    ///     \frac{1}{\sqrt{2}}
    ///     \begin{bmatrix}
    ///         1 & 1 \\\\
    ///         1 & -1
    ///     \end{bmatrix}.
    /// \end{align}
    ///
    /// # Input
    /// ## qubit
    /// Qubit to which the gate should be applied.
    internal operation ApplyUncontrolledH (qubit : Qubit) : Unit is Adj {
        body (...) {
            ApplyUncontrolledX(qubit);
            ApplyUncontrolledSqrtX(qubit);
            Rz(-PI() / 2.0, qubit);
            ApplyUncontrolledSqrtX(qubit);
            ApplyUncontrolledX(qubit);
        }
        adjoint self;
    }
}

// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Intrinsic {

    /// # Summary
    /// Applies the Pauli $Y$ gate. Note that the Controlled functor is not supported.
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
    internal operation ApplyUncontrolledY (qubit : Qubit) : Unit is Adj {
        body (...) {
            ApplyUncontrolledH(qubit);
            ApplyUncontrolledS(qubit);
            ApplyUncontrolledH(qubit);

            ApplyUncontrolledZ(qubit);

            ApplyUncontrolledH(qubit);
            ApplyUncontrolledSAdj(qubit);
            ApplyUncontrolledH(qubit);
        }
        adjoint self;
    }
}
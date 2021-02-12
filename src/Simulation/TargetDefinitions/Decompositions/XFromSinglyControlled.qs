// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Intrinsic {

    /// # Summary
    /// Applies the Pauli $X$ gate.
    ///
    /// # Description
    /// \begin{align}
    ///     \sigma_x \mathrel{:=}
    ///     \begin{bmatrix}
    ///         0 & 1 \\\\
    ///         1 & 0
    ///     \end{bmatrix}.
    /// \end{align}
    ///
    /// # Input
    /// ## qubit
    /// Qubit to which the gate should be applied.
    operation X (qubit : Qubit) : Unit is Adj + Ctl {
        body (...) {
            ApplyUncontrolledX(qubit);
        }
        controlled (ctls, ...) {
            if (Length(ctls) == 0) {
                ApplyUncontrolledX(qubit);
            }
            elif (Length(ctls) == 1) {
                ApplyControlledX(ctls[0], qubit);
            }
            elif (Length(ctls) == 2) {
                CCNOT(ctls[0], ctls[1], qubit);
            }
            else {
                ApplyWithLessControlsA(Controlled X, (ctls, qubit));
            }
        }
        adjoint self;
    }
}
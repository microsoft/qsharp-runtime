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
        body (...) {
            ApplyUncontrolledY(qubit);
        }
        controlled (ctls, ...) {
            if (Length(ctls) == 0) {
                ApplyUncontrolledY(qubit);
            }
            elif (Length(ctls) == 1) {
                within {
                    MapPauli(qubit, PauliX, PauliY);
                }
                apply {
                    CNOT(ctls[0], qubit);
                }
            }
            elif (Length(ctls) == 2) {
                within {
                    MapPauli(qubit, PauliZ, PauliY);
                }
                apply {
                    Controlled Z(ctls, qubit);
                }
            }
            else {
                ApplyWithLessControlsA(Controlled Y, (ctls, qubit));
            }
        }
        adjoint self;
    }
}
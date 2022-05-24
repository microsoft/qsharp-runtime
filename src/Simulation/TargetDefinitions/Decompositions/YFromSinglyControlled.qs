// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Intrinsic {
    open Microsoft.Quantum.Canon;

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
                CY(ctls[0], qubit);
            }
            elif (Length(ctls) == 2) {
                CCY(ctls[0], ctls[1], qubit);
            }
            else {
                use aux = Qubit[Length(ctls) - 2];
                within {
                    CollectControls(ctls, aux, 1 - (Length(ctls) % 2));
                }
                apply {
                    if Length(ctls) % 2 != 0 {
                        CCY(ctls[Length(ctls) - 1], aux[Length(ctls) - 3], qubit);
                    }
                    else {
                        CCY(aux[Length(ctls) - 3], aux[Length(ctls) - 4], qubit);
                    }
                }
            }
        }
        adjoint self;
    }

    operation CCY(control1 : Qubit, control2 : Qubit, target : Qubit) : Unit is Adj {
        within {
            MapPauli(target, PauliZ, PauliY);
        }
        apply {
            CCZ(control1, control2, target);
        }
    }
}
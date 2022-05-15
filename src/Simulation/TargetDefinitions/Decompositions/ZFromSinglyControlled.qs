// Copyright (c) Microsoft Corporation.
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
        body (...) {
            ApplyUncontrolledZ(qubit);
        }
        controlled (ctls, ...) {
            if Length(ctls) == 0 {
                ApplyUncontrolledZ(qubit);
            }
            elif Length(ctls) == 1 {
                ApplyControlledZ(ctls[0], qubit);
            }
            elif Length(ctls) == 2 {
                CCZ(ctls[0], ctls[1], qubit);
            }
            else {
                use aux = Qubit[Length(ctls) - 1 - (Length(ctls) % 2)];
                within {
                    CollectControls(ctls, aux);
                }
                apply {
                    if Length(ctls) % 2 != 0 {
                        CCZ(ctls[Length(ctls) - 1], aux[Length(ctls) - 3], qubit);
                    }
                    else {
                        CCZ(aux[Length(ctls) - 3], aux[Length(ctls) - 4], qubit);
                    }
                }
            }
        }
        adjoint self;
    }
}
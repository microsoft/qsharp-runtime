// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Intrinsic {
    open Microsoft.Quantum.Canon;

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
            if (Length(ctls) == 0) {
                ApplyUncontrolledZ(qubit);
            }
            elif (Length(ctls) == 1) {
                ApplyControlledZ(ctls[0], qubit);
            }
            elif (Length(ctls) == 2) {
                CCZ(ctls[0], ctls[1], qubit);
            }
            else {
                ApplyWithLessControlsA(Controlled Z, (ctls, qubit));
            }
        }
        adjoint self;
    }
}
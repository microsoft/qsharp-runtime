// Copyright (c) Microsoft Corporation. All rights reserved.
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
            if (Length(ctls) == 0) {
                ApplyUncontrolledZ(qubit);
            }
            elif (Length(ctls) == 1) {
                ApplyControlledZ(ctls[0], qubit);
            }
            elif (Length(ctls) == 2) {
                // [Page 15 of arXiv:1206.0758v3](https://arxiv.org/pdf/1206.0758v3.pdf#page=15)
                Adjoint T(ctls[0]);
                Adjoint T(ctls[1]);
                CNOT(qubit, ctls[0]);
                T(ctls[0]);
                CNOT(ctls[1], qubit);
                CNOT(ctls[1], ctls[0]);
                T(qubit);
                Adjoint T(ctls[0]);
                CNOT(ctls[1], qubit);
                CNOT(qubit, ctls[0]);
                Adjoint T(qubit);
                T(ctls[0]);
                CNOT(ctls[1], ctls[0]);
            }
            else {
                ApplyWithLessControlsA(Controlled Z, (ctls, qubit));
            }
        }
        adjoint self;
    }
}
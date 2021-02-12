// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Intrinsic {

    /// # Summary
    /// Applies a rotation about the $z$-axis by a given angle.
    ///
    /// # Description
    /// \begin{align}
    ///     R_z(\theta) \mathrel{:=}
    ///     e^{-i \theta \sigma_z / 2} = 
    ///     \begin{bmatrix}
    ///         e^{-i \theta / 2} & 0 \\\\
    ///         0 & e^{i \theta / 2}
    ///     \end{bmatrix}.
    /// \end{align}
    ///
    /// # Input
    /// ## theta
    /// Angle about which the qubit is to be rotated.
    /// ## qubit
    /// Qubit to which the gate should be applied.
    ///
    /// # Remarks
    /// Equivalent to:
    /// ```qsharp
    /// R(PauliZ, theta, qubit);
    /// ```
    operation Rz (theta : Double, qubit : Qubit) : Unit is Adj + Ctl {
        body (...) {
            ApplyUncontrolledRz(theta, qubit);
        }
        controlled (ctls, ...) {
            if (Length(ctls) == 0) {
                Rz(theta, qubit);
            }
            elif (Length(ctls) == 1) {
                Rz(theta/2.0, qubit);
                CNOT(ctls[0], qubit);
                Rz(-theta/2.0, qubit);
                CNOT(ctls[0], qubit);
            }
            else {
                ApplyWithLessControlsA(Controlled Rz, (ctls, (theta, qubit)));
            }
        }
        adjoint (...) {
            Rz(-theta, qubit);
        }
    }
}
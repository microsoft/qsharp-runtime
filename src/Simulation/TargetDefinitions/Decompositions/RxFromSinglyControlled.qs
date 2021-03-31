// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Intrinsic {

    /// # SummaRx
    /// Applies a rotation about the $x$-axis by a given angle.
    ///
    /// # Description
    /// \begin{align}
    ///     R_x(\theta) \mathrel{:=}
    ///     e^{-i \theta \sigma_x / 2} = 
    ///     \begin{bmatrix}
    ///         \cos \frac{\theta}{2} & -i\sin \frac{\theta}{2}  \\\\
    ///         -i\sin \frac{\theta}{2} & \cos \frac{\theta}{2}
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
    /// R(PauliX, theta, qubit);
    /// ```
    operation Rx (theta : Double, qubit : Qubit) : Unit is Adj + Ctl {
        body (...) {
            ApplyUncontrolledRx(theta, qubit);
        }
        controlled (ctls, ...) {
            if (Length(ctls) == 0) {
                ApplyUncontrolledRx(theta, qubit);
            }
            elif (Length(ctls) == 1) {
                within {
                    MapPauli(qubit, PauliZ, PauliX);
                }
                apply {
                    Controlled Rz(ctls, (theta, qubit));
                }
            }
            else {
                ApplyWithLessControlsA(Controlled Rx, (ctls, (theta, qubit)));
            }
        }
        adjoint (...) {
            Rx(-theta, qubit);
        }
    }
}
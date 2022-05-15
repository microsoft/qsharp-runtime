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
            if Length(ctls) == 0 {
                ApplyUncontrolledRz(theta, qubit);
            }
            elif Length(ctls) == 1 {
                CRz(ctls[0], theta, qubit);
            }
            else {
                use aux = Qubit[Length(ctls) - 1];
                within {
                    CollectControls(ctls, aux);
                    AdjustForSingleControl(ctls, aux);
                }
                apply {
                    CRz(aux[Length(ctls) - 2], theta, qubit);
                }
            }
        }
        adjoint (...) {
            Rz(-theta, qubit);
        }
    }

    internal operation CRz(control : Qubit, theta : Double, target : Qubit) : Unit is Adj {
        Rz(theta / 2.0, target);
        CNOT(control, target);
        Rz(-theta / 2.0, target);
        CNOT(control, target);
    }
}
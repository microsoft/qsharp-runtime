// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Intrinsic {
    open Microsoft.Quantum.Targeting;

    /// # Summary
    /// Applies the two qubit Ising $YY$ rotation gate.
    ///
    /// # Description
    /// \begin{align}
    ///     R_yy(\theta) \mathrel{:=}
    ///     \begin{bmatrix}
    ///         \cos \theta & 0 & 0 & i\sin \theta  \\\\
    ///         0 & \cos \theta & -i\sin \theta & 0  \\\\
    ///         0 & -i\sin \theta & \cos \theta & 0  \\\\
    ///         i\sin \theta & 0 & 0 & \cos \theta
    ///     \end{bmatrix}.
    /// \end{align}
    ///
    /// # Input
    /// ## theta
    /// The angle about which the qubits are rotated.
    /// ## qubit0
    /// The first qubit input to the gate.
    /// ## qubit1
    /// The second qubit input to the gate.
    operation Ryy (theta : Double, qubit0 : Qubit, qubit1 : Qubit) : Unit is Adj + Ctl {
        body (...) {
            ApplyUncontrolledRyy(theta, qubit0, qubit1);
        }
        controlled (ctls, ...) {
            if Length(ctls) == 0 {
                ApplyUncontrolledRyy(theta, qubit0, qubit1);
            }
            elif Length(ctls) == 1 {
                CRyy(ctls[0], theta, qubit0, qubit1);
            }
            else {
                use aux = Qubit[Length(ctls) - 1];
                within {
                    CollectControls(ctls, aux, 0);
                    AdjustForSingleControl(ctls, aux);
                }
                apply {
                    CRyy(aux[Length(ctls) - 2], theta, qubit0, qubit1);
                }
            }
        }
        adjoint (...) {
            Ryy(-theta, qubit0, qubit1);
        }
    }

    internal operation CRyy (control : Qubit, theta : Double, qubit0 : Qubit, qubit1 : Qubit) : Unit {
        within {
            CNOT(qubit1, qubit0);
        }
        apply {
            Controlled Ry([control], (theta, qubit0));
        }
    }
}
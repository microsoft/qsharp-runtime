// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Intrinsic {
    open Microsoft.Quantum.Targeting;

    /// # Summary
    /// Applies the two qubit Ising $XX$ rotation gate.
    ///
    /// # Description
    /// \begin{align}
    ///     R_xx(\theta) \mathrel{:=}
    ///     \begin{bmatrix}
    ///         \cos \theta & 0 & 0 & -i\sin \theta  \\\\
    ///         0 & \cos \theta & -i\sin \theta & 0  \\\\
    ///         0 & -i\sin \theta & \cos \theta & 0  \\\\
    ///         -i\sin \theta & 0 & 0 & \cos \theta
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
    operation Rxx (theta : Double, qubit0 : Qubit, qubit1 : Qubit) : Unit is Adj + Ctl {
        body (...) {
            ApplyUncontrolledRxx(theta, qubit0, qubit1);
        }
        controlled (ctls, ...) {
            if Length(ctls) == 0 {
                ApplyUncontrolledRxx(theta, qubit0, qubit1);
            }
            elif Length(ctls) == 1 {
                CRxx(ctls[0], theta, qubit0, qubit1);
            }
            else {
                use aux = Qubit[Length(ctls) - 1];
                within {
                    CollectControls(ctls, aux, 0);
                    AdjustForSingleControl(ctls, aux);
                }
                apply {
                    CRxx(aux[Length(ctls) - 2], theta, qubit0, qubit1);
                }
            }
        }
        adjoint (...) {
            Rxx(-theta, qubit0, qubit1);
        }
    }

    internal operation CRxx (control : Qubit, theta : Double, qubit0 : Qubit, qubit1 : Qubit) : Unit {
        within {
            CNOT(qubit1, qubit0);
        }
        apply {
            Controlled Rx([control], (theta, qubit0));
        }
    }
}
// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Intrinsic {
    open Microsoft.Quantum.Targeting;

    /// # Summary
    /// Applies the two qubit Ising $ZZ$ rotation gate.
    ///
    /// # Description
    /// \begin{align}
    ///     R_zz(\theta) \mathrel{:=}
    ///     \begin{bmatrix}
    ///         e^{-i \theta / 2} & 0 & 0 & 0 \\\\
    ///         0 & e^{-i \theta / 2} & 0 & 0 \\\\
    ///         0 & 0 & e^{-i \theta / 2} & 0 \\\\
    ///         0 & 0 & 0 & e^{i \theta / 2}
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
    operation Rzz (theta : Double, qubit0 : Qubit, qubit1 : Qubit) : Unit is Adj + Ctl {
        body (...) {
            ApplyUncontrolledRzz(theta, qubit0, qubit1);
        }
        controlled (ctls, ...) {
            if Length(ctls) == 0 {
                ApplyUncontrolledRzz(theta, qubit0, qubit1);
            }
            elif Length(ctls) == 1 {
                CRzz(ctls[0], theta, qubit0, qubit1);
            }
            else {
                use aux = Qubit[Length(ctls) - 1];
                within {
                    CollectControls(ctls, aux, 0);
                    AdjustForSingleControl(ctls, aux);
                }
                apply {
                    CRzz(aux[Length(ctls) - 2], theta, qubit0, qubit1);
                }
            }
        }
        adjoint (...) {
            Rzz(-theta, qubit0, qubit1);
        }
    }

    internal operation CRzz (control : Qubit, theta : Double, qubit0 : Qubit, qubit1 : Qubit) : Unit {
        within {
            CNOT(qubit1, qubit0);
        }
        apply {
            Controlled Rz([control], (theta, qubit0));
        }
    }
}
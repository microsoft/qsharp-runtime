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
                ApplyUncontrolledRz(theta, qubit);
            }
            elif Length(ctls) == 1 {
                CRz(ctls[0], theta, qubit);
            }
            elif Length(ctls) == 2 {
                use temp = Qubit();
                within {
                    PhaseCCX(ctls[0], ctls[1], temp);
                }
                apply {
                    CRz(temp, theta, qubit);
                }
            }
            elif Length(ctls) == 3 {
                use temps = Qubit[2];
                within {
                    PhaseCCX(ctls[0], ctls[1], temps[0]);
                    PhaseCCX(ctls[2], temps[0], temps[1]);
                }
                apply {
                    CRz(temps[1], theta, qubit);
                }
            }
            elif Length(ctls) == 4 {
                use temps = Qubit[3];
                within {
                    PhaseCCX(ctls[0], ctls[1], temps[0]);
                    PhaseCCX(ctls[2], ctls[3], temps[1]);
                    PhaseCCX(temps[0], temps[1], temps[2]);
                }
                apply {
                    CRz(temps[2], theta, qubit);
                }
            }
            elif Length(ctls) == 5 {
                use temps = Qubit[4];
                within {
                    PhaseCCX(ctls[0], ctls[1], temps[0]);
                    PhaseCCX(ctls[2], ctls[3], temps[1]);
                    PhaseCCX(ctls[4], temps[0], temps[2]);
                    PhaseCCX(temps[1], temps[2], temps[3]);
                }
                apply {
                    CRz(temps[3], theta, qubit);
                }
            }
            elif Length(ctls) == 6 {
                use temps = Qubit[5];
                within {
                    PhaseCCX(ctls[0], ctls[1], temps[0]);
                    PhaseCCX(ctls[2], ctls[3], temps[1]);
                    PhaseCCX(ctls[4], ctls[5], temps[2]);
                    PhaseCCX(temps[0], temps[1], temps[3]);
                    PhaseCCX(temps[2], temps[3], temps[4]);
                }
                apply {
                    CRz(temps[4], theta, qubit);
                }
            }
            elif Length(ctls) == 7 {
                use temps = Qubit[6];
                within {
                    PhaseCCX(ctls[0], ctls[1], temps[0]);
                    PhaseCCX(ctls[2], ctls[3], temps[1]);
                    PhaseCCX(ctls[4], ctls[5], temps[2]);
                    PhaseCCX(ctls[6], temps[0], temps[3]);
                    PhaseCCX(temps[1], temps[2], temps[4]);
                    PhaseCCX(temps[3], temps[4], temps[5]);
                }
                apply {
                    CRz(temps[5], theta, qubit);
                }
            }
            elif Length(ctls) == 8 {
                use temps = Qubit[7];
                within {
                    PhaseCCX(ctls[0], ctls[1], temps[0]);
                    PhaseCCX(ctls[2], ctls[3], temps[1]);
                    PhaseCCX(ctls[4], ctls[5], temps[2]);
                    PhaseCCX(ctls[6], ctls[7], temps[3]);
                    PhaseCCX(temps[0], temps[1], temps[4]);
                    PhaseCCX(temps[2], temps[3], temps[5]);
                    PhaseCCX(temps[4], temps[5], temps[6]);
                }
                apply {
                    CRz(temps[6], theta, qubit);
                }
            }
            else {
                fail "Too many control qubits specified to Rz gate.";

                // Eventually, we can use recursion via callables with the below utility:
                // ApplyWithLessControlsA(Controlled Rz, (ctls, qubit));
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
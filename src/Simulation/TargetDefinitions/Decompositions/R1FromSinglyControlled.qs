// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Intrinsic {

    /// # Summary
    /// Applies a rotation about the $\ket{1}$ state by a given angle.
    ///
    /// # Description
    /// \begin{align}
    ///     R_1(\theta) \mathrel{:=}
    ///     \operatorname{diag}(1, e^{i\theta}).
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
    /// R(PauliI, -theta, qubit);
    /// ```
    operation R1 (theta : Double, qubit : Qubit) : Unit is Adj + Ctl {
        body (...) {
            Rz(theta, qubit);
        }
        controlled (ctls, ...) {
            if Length(ctls) == 0 {
                Rz(theta, qubit);
            }
            elif Length(ctls) == 1 {
                CR1(theta, ctls[0], qubit);
            }
            elif Length(ctls) == 2 {
                use temp = Qubit();
                within {
                    PhaseCCX(ctls[0], ctls[1], temp);
                }
                apply {
                    CR1(theta, temp, qubit);
                }
            }
            elif Length(ctls) == 3 {
                use temps = Qubit[2];
                within {
                    PhaseCCX(ctls[0], ctls[1], temps[0]);
                    PhaseCCX(ctls[2], temps[0], temps[1]);
                }
                apply {
                    CR1(theta, temps[1], qubit);
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
                    CR1(theta, temps[2], qubit);
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
                    CR1(theta, temps[3], qubit);
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
                    CR1(theta, temps[4], qubit);
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
                    CR1(theta, temps[5], qubit);
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
                    CR1(theta, temps[6], qubit);
                }
            }
            else {
                fail "Too many control qubits specified to R1 gate.";
            }
        }

        // R(PauliZ, theta, qubit);
        // R(PauliI, -theta, qubit);
    }

    internal operation CR1(theta : Double, control : Qubit, target : Qubit) : Unit is Adj {
        Rz(theta/2.0, target);
        Rz(theta/2.0, control);
        CNOT(control,target);
        Rz(-theta/2.0, target);
        CNOT(control,target);
    }

}
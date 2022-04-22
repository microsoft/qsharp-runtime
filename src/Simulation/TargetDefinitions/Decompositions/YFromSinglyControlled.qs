// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Intrinsic {
    open Microsoft.Quantum.Canon;

    /// # Summary
    /// Applies the Pauli $Y$ gate.
    ///
    /// # Description
    /// \begin{align}
    ///     \sigma_y \mathrel{:=}
    ///     \begin{bmatrix}
    ///         0 & -i \\\\
    ///         i & 0
    ///     \end{bmatrix}.
    /// \end{align}
    ///
    /// # Input
    /// ## qubit
    /// Qubit to which the gate should be applied.
    operation Y (qubit : Qubit) : Unit is Adj + Ctl {
        body (...) {
            ApplyUncontrolledY(qubit);
        }
        controlled (ctls, ...) {
            if (Length(ctls) == 0) {
                ApplyUncontrolledY(qubit);
            }
            elif (Length(ctls) == 1) {
                CY(ctls[0], qubit);
            }
            elif (Length(ctls) == 2) {
                CCY(ctls[0], ctls[1], qubit);
            }
            elif Length(ctls) == 3 {
                use temp = Qubit();
                within {
                    PhaseCCX(ctls[0], ctls[1], temp);
                }
                apply {
                    CCY(temp, ctls[2], qubit);
                }
            }
            elif Length(ctls) == 4 {
                use temps = Qubit[2];
                within {
                    PhaseCCX(ctls[0], ctls[1], temps[0]);
                    PhaseCCX(ctls[2], ctls[3], temps[1]);
                }
                apply {
                    CCY(temps[0], temps[1], qubit);
                }
            }
            elif Length(ctls) == 5 {
                use temps = Qubit[3];
                within {
                    PhaseCCX(ctls[0], ctls[1], temps[0]);
                    PhaseCCX(ctls[2], ctls[3], temps[1]);
                    PhaseCCX(temps[0], temps[1], temps[2]);
                }
                apply {
                    CCY(temps[2], ctls[4], qubit);
                }
            }
            elif Length(ctls) == 6 {
                use temps = Qubit[4];
                within {
                    PhaseCCX(ctls[0], ctls[1], temps[0]);
                    PhaseCCX(ctls[2], ctls[3], temps[1]);
                    PhaseCCX(ctls[4], ctls[5], temps[2]);
                    PhaseCCX(temps[0], temps[1], temps[3]);
                }
                apply {
                    CCY(temps[2], temps[3], qubit);
                }
            }
            elif Length(ctls) == 7 {
                use temps = Qubit[5];
                within {
                    PhaseCCX(ctls[0], ctls[1], temps[0]);
                    PhaseCCX(ctls[2], ctls[3], temps[1]);
                    PhaseCCX(ctls[4], ctls[5], temps[2]);
                    PhaseCCX(temps[0], temps[1], temps[3]);
                    PhaseCCX(temps[2], temps[3], temps[4]);
                }
                apply {
                    CCY(temps[4], ctls[6], qubit);
                }
            }
            elif Length(ctls) == 8 {
                use temps = Qubit[6];
                within {
                    PhaseCCX(ctls[0], ctls[1], temps[0]);
                    PhaseCCX(ctls[2], ctls[3], temps[1]);
                    PhaseCCX(ctls[4], ctls[5], temps[2]);
                    PhaseCCX(ctls[6], ctls[7], temps[3]);
                    PhaseCCX(temps[0], temps[1], temps[4]);
                    PhaseCCX(temps[2], temps[3], temps[5]);
                }
                apply {
                    CCY(temps[4], temps[5], qubit);
                }
            }
            else {
                fail "Too many control qubits specified to Y gate.";

                // Eventually, we can use recursion via callables with the below utility:
                // ApplyWithLessControlsA(Controlled Y, (ctls, qubit));
            }
        }
        adjoint self;
    }

    internal operation CCY(control1 : Qubit, control2 : Qubit, target : Qubit) : Unit is Adj {
        within {
            MapPauli(target, PauliZ, PauliY);
        }
        apply {
            CCZ(control1, control2, target);
        }
    }
}
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Intrinsic {

    /// # Summary
    /// Applies the Pauli $X$ gate.
    ///
    /// # Description
    /// \begin{align}
    ///     \sigma_x \mathrel{:=}
    ///     \begin{bmatrix}
    ///         0 & 1 \\\\
    ///         1 & 0
    ///     \end{bmatrix}.
    /// \end{align}
    ///
    /// # Input
    /// ## qubit
    /// Qubit to which the gate should be applied.
    operation X (qubit : Qubit) : Unit is Adj + Ctl {
        body (...) {
            ApplyUncontrolledX(qubit);
        }
        controlled (ctls, ...) {
            if Length(ctls) == 0 {
                ApplyUncontrolledX(qubit);
            }
            elif Length(ctls) == 1 {
                ApplyControlledX(ctls[0], qubit);
            }
            elif Length(ctls) == 2 {
                CCNOT(ctls[0], ctls[1], qubit);
            }
            elif Length(ctls) == 3 {
                use temp = Qubit();
                within {
                    PhaseCCX(ctls[0], ctls[1], temp);
                }
                apply {
                    CCNOT(temp, ctls[2], qubit);
                }
            }
            elif Length(ctls) == 4 {
                use temps = Qubit[2];
                within {
                    PhaseCCX(ctls[0], ctls[1], temps[0]);
                    PhaseCCX(ctls[2], ctls[3], temps[1]);
                }
                apply {
                    CCNOT(temps[0], temps[1], qubit);
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
                    CCNOT(temps[2], ctls[4], qubit);
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
                    CCNOT(temps[2], temps[3], qubit);
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
                    CCNOT(temps[4], ctls[6], qubit);
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
                    CCNOT(temps[4], temps[5], qubit);
                }
            }
            else {
                fail "Too many control qubits specified to X gate.";

                // Eventually, we can use recursion via callables with the below utility:
                // ApplyWithLessControlsA(Controlled X, (ctls, qubit));
            }
        }
        adjoint self;
    }
}
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Intrinsic {

    /// # Summary
    /// Applies the π/4 phase gate to a single qubit.
    ///
    /// # Description
    /// \begin{align}
    ///     S \mathrel{:=}
    ///     \begin{bmatrix}
    ///         1 & 0 \\\\
    ///         0 & i
    ///     \end{bmatrix}.
    /// \end{align}
    ///
    /// # Input
    /// ## qubit
    /// Qubit to which the gate should be applied.
    operation S (qubit : Qubit) : Unit is Adj + Ctl {
        body (...) {
            ApplyUncontrolledS(qubit);
        }
        adjoint (...) {
            ApplyUncontrolledSAdj(qubit);
        }
        controlled (ctls, ...) {
            if Length(ctls) == 0 {
                ApplyUncontrolledS(qubit);
            }
            elif Length(ctls) == 1 {
                CS(ctls[0], qubit);
            }
            elif Length(ctls) == 2 {
                Controlled CS([ctls[0]], (ctls[1], qubit));
            }
            elif Length(ctls) == 3 {
                use temp = Qubit();
                within {
                    PhaseCCX(ctls[0], ctls[1], temp);
                }
                apply {
                    Controlled CS([temp], (ctls[2], qubit));
                }
            }
            elif Length(ctls) == 4 {
                use temps = Qubit[2];
                within {
                    PhaseCCX(ctls[0], ctls[1], temps[0]);
                    PhaseCCX(ctls[2], ctls[3], temps[1]);
                }
                apply {
                    Controlled CS([temps[0]], (temps[1], qubit));
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
                    Controlled CS([temps[2]], (ctls[4], qubit));
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
                    Controlled CS([temps[2]], (temps[3], qubit));
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
                    Controlled CS([temps[4]], (ctls[6], qubit));
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
                    Controlled CS([temps[4]], (temps[5], qubit));
                }
            }
            else {
                fail "Too many control qubits specified to S gate.";

                // Eventually, we can use recursion via callables with the below utility:
                // ApplyWithLessControlsA(Controlled S, (ctls, qubit));
            }
        }
        controlled adjoint (ctls, ...) {
            if Length(ctls) == 0 {
                ApplyUncontrolledSAdj(qubit);
            }
            elif Length(ctls) == 1 {
                Adjoint CS(ctls[0], qubit);
            }
            elif Length(ctls) == 2 {
                Controlled Adjoint CS([ctls[0]], (ctls[1], qubit));
            }
            elif Length(ctls) == 3 {
                use temp = Qubit();
                within {
                    PhaseCCX(ctls[0], ctls[1], temp);
                }
                apply {
                    Controlled Adjoint CS([temp], (ctls[2], qubit));
                }
            }
            elif Length(ctls) == 4 {
                use temps = Qubit[2];
                within {
                    PhaseCCX(ctls[0], ctls[1], temps[0]);
                    PhaseCCX(ctls[2], ctls[3], temps[1]);
                }
                apply {
                    Controlled Adjoint CS([temps[0]], (temps[1], qubit));
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
                    Controlled Adjoint CS([temps[2]], (ctls[4], qubit));
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
                    Controlled Adjoint CS([temps[2]], (temps[3], qubit));
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
                    Controlled Adjoint CS([temps[4]], (ctls[6], qubit));
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
                    Controlled Adjoint CS([temps[4]], (temps[5], qubit));
                }
            }
            else {
                fail "Too many control qubits specified to Adjoint S gate.";

                // Eventually, we can use recursion via callables with the below utility:
                // ApplyWithLessControlsA(Controlled Adjoint S, (ctls, qubit));
            }
        }
    }

    internal operation CS(control : Qubit, target : Qubit) : Unit is Adj + Ctl {
        T(control);
        T(target);
        CNOT(control, target);
        Adjoint T(target);
        CNOT(control, target);
    }
}
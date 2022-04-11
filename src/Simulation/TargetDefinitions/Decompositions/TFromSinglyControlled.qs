// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Intrinsic {
    open Microsoft.Quantum.Math;

    /// # Summary
    /// Applies the π/8 gate to a single qubit.
    ///
    /// # Description
    /// \begin{align}
    ///     T \mathrel{:=}
    ///     \begin{bmatrix}
    ///         1 & 0 \\\\
    ///         0 & e^{i \pi / 4}
    ///     \end{bmatrix}.
    /// \end{align}
    ///
    /// # Input
    /// ## qubit
    /// Qubit to which the gate should be applied.
    operation T (qubit : Qubit) : Unit is Adj + Ctl {
        body (...) {
            ApplyUncontrolledT(qubit);
        }
        adjoint (...) {
            ApplyUncontrolledTAdj(qubit);
        }
        controlled (ctls, ...) {
            if Length(ctls) == 0 {
                ApplyUncontrolledT(qubit);
            }
            elif Length(ctls) == 1 {
                CT(ctls[0], qubit);
            }
            elif Length(ctls) == 2 {
                use temp = Qubit();
                within {
                    PhaseCCX(ctls[0], ctls[1], temp);
                }
                apply {
                    CT(temp, qubit);
                }
            }
            elif Length(ctls) == 3 {
                use temps = Qubit[2];
                within {
                    PhaseCCX(ctls[0], ctls[1], temps[0]);
                    PhaseCCX(ctls[2], temps[0], temps[1]);
                }
                apply {
                    CT(temps[1], qubit);
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
                    CT(temps[2], qubit);
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
                    CT(temps[3], qubit);
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
                    CT(temps[4], qubit);
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
                    CT(temps[5], qubit);
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
                    CT(temps[5], qubit);
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
                    CT(temps[6], qubit);
                }
            }
            else {
                fail "Too many control qubits specified to T gate.";

                // Eventually, we can use recursion via callables with the below utility:
                // ApplyWithLessControlsA(Controlled T, (ctls, qubit));
            }
        }
        controlled adjoint (ctls, ...) {
            if Length(ctls) == 0 {
                ApplyUncontrolledTAdj(qubit);
            }
            elif Length(ctls) == 1 {
                Adjoint CT(ctls[0], qubit);
            }
            elif Length(ctls) == 2 {
                use temp = Qubit();
                within {
                    PhaseCCX(ctls[0], ctls[1], temp);
                }
                apply {
                    Adjoint CT(temp, qubit);
                }
            }
            elif Length(ctls) == 3 {
                use temps = Qubit[2];
                within {
                    PhaseCCX(ctls[0], ctls[1], temps[0]);
                    PhaseCCX(ctls[2], temps[0], temps[1]);
                }
                apply {
                    Adjoint CT(temps[1], qubit);
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
                    Adjoint CT(temps[2], qubit);
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
                    Adjoint CT(temps[3], qubit);
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
                    Adjoint CT(temps[4], qubit);
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
                    Adjoint CT(temps[5], qubit);
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
                    Adjoint CT(temps[6], qubit);
                }
            }
            else {
                fail "Too many control qubits specified to Adjoint T gate.";

                // Eventually, we can use recursion via callables with the below utility:
                // ApplyWithLessControlsA(Controlled Adjoint T, (ctls, qubit));
            }
        }
    }

    internal operation CT(control : Qubit, target : Qubit) : Unit is Adj {
        let angle = PI() / 8.0;
        Rz(angle, control);
        Rz(angle, target);
        CNOT(control, target);
        Adjoint Rz(angle, target);
        CNOT(control, target);
    }
}
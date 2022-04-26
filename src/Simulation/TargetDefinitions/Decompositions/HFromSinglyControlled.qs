// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Intrinsic {

    /// # Summary
    /// Applies the Hadamard transformation to a single qubit.
    ///
    /// # Description
    /// \begin{align}
    ///     H \mathrel{:=}
    ///     \frac{1}{\sqrt{2}}
    ///     \begin{bmatrix}
    ///         1 & 1 \\\\
    ///         1 & -1
    ///     \end{bmatrix}.
    /// \end{align}
    ///
    /// # Input
    /// ## qubit
    /// Qubit to which the gate should be applied.
    operation H (qubit : Qubit) : Unit is Adj + Ctl {
        body (...) {
            ApplyUncontrolledH(qubit);
        }
        controlled (ctls, ...) {
            if Length(ctls) == 0 {
                ApplyUncontrolledH(qubit);
            }
            elif Length(ctls) == 1 {
                CH(ctls[0], qubit);
            }
            elif Length(ctls) == 2 {
                CCH(ctls[0], ctls[1], qubit);
            }
            elif Length(ctls) == 3 {
                use temp = Qubit();
                within {
                    PhaseCCX(ctls[0], ctls[1], temp);
                }
                apply {
                    CCH(temp, ctls[2], qubit);
                }
            }
            elif Length(ctls) == 4 {
                use temps = Qubit[2];
                within {
                    PhaseCCX(ctls[0], ctls[1], temps[0]);
                    PhaseCCX(ctls[2], ctls[3], temps[1]);
                }
                apply {
                    CCH(temps[0], temps[1], qubit);
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
                    CCH(temps[2], ctls[4], qubit);
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
                    CCH(temps[2], temps[3], qubit);
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
                    CCH(temps[4], ctls[6], qubit);
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
                    CCH(temps[4], temps[5], qubit);
                }
            }
            else {
                fail "Too many control qubits specified to H gate.";

                // Eventually, we can use recursion via callables with the below utility:
                // ApplyWithLessControlsA(Controlled H, (ctls, qubit));
            }
        }
        adjoint self;
    }

    internal operation CH(control : Qubit, target : Qubit) : Unit is Adj {
        within {
            S(target);
            H(target);
            T(target);
        }
        apply {
            CNOT(control, target);
        }
    }

    internal operation CCH(control1 : Qubit, control2 : Qubit, target : Qubit) : Unit is Adj {
        within {
            S(target);
            H(target);
            T(target);
        }
        apply {
            CCNOT(control1, control2, target);
        }
    }
}
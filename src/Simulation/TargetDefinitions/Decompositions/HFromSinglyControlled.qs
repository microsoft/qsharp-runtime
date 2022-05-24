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
            else {
                use aux = Qubit[Length(ctls) - 1 - (Length(ctls) % 2)];
                within {
                    CollectControls(ctls, aux, 0);
                }
                apply {
                    if Length(ctls) % 2 != 0 {
                        CCH(ctls[Length(ctls) - 1], aux[Length(ctls) - 3], qubit);
                    }
                    else {
                        CCH(aux[Length(ctls) - 3], aux[Length(ctls) - 4], qubit);
                    }
                }
            }
        }
        adjoint self;
    }

    operation CH(control : Qubit, target : Qubit) : Unit is Adj {
        within {
            S(target);
            H(target);
            T(target);
        }
        apply {
            CNOT(control, target);
        }
    }

    operation CCH(control1 : Qubit, control2 : Qubit, target : Qubit) : Unit is Adj {
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
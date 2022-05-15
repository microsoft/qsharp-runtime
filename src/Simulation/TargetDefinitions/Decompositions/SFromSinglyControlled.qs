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
            else {
                use aux = Qubit[Length(ctls) - 1 - (Length(ctls) % 2)];
                within {
                    CollectControls(ctls, aux);
                }
                apply {
                    if Length(ctls) % 2 != 0 {
                        Controlled CS([ctls[Length(ctls) - 1]], (aux[Length(ctls) - 3], qubit));
                    }
                    else {
                        Controlled CS([aux[Length(ctls) - 3]], (aux[Length(ctls) - 4], qubit));
                    }
                }
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
            else {
                use aux = Qubit[Length(ctls) - 1 - (Length(ctls) % 2)];
                within {
                    CollectControls(ctls, aux);
                }
                apply {
                    if Length(ctls) % 2 != 0 {
                        Controlled Adjoint CS([ctls[Length(ctls) - 1]], (aux[Length(ctls) - 3], qubit));
                    }
                    else {
                        Controlled Adjoint CS([aux[Length(ctls) - 3]], (aux[Length(ctls) - 4], qubit));
                    }
                }
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
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
            else {
                use aux = Qubit[Length(ctls) - 1];
                within {
                    CollectControls(ctls, aux, 0);
                    AdjustForSingleControl(ctls, aux);
                }
                apply {
                    CT(aux[Length(ctls) - 2], qubit);
                }
            }
        }
        controlled adjoint (ctls, ...) {
            if Length(ctls) == 0 {
                ApplyUncontrolledTAdj(qubit);
            }
            elif Length(ctls) == 1 {
                Adjoint CT(ctls[0], qubit);
            }
            else {
                use aux = Qubit[Length(ctls) - 1];
                within {
                    CollectControls(ctls, aux, 0);
                    AdjustForSingleControl(ctls, aux);
                }
                apply {
                    Adjoint CT(aux[Length(ctls) - 2], qubit);
                }
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
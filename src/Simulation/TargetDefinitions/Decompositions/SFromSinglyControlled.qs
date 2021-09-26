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
            if (Length(ctls) == 0) {
                ApplyUncontrolledS(qubit);
            }
            elif (Length(ctls) == 1) {
                T(ctls[0]);
                T(qubit);
                CNOT(ctls[0], qubit);
                Adjoint T(qubit);
                CNOT(ctls[0], qubit);
            }
            else {
                ApplyWithLessControlsA(Controlled S, (ctls, qubit));
            }
        }
        controlled adjoint (ctls, ...) {
            if (Length(ctls) == 0) {
                ApplyUncontrolledSAdj(qubit);
            }
            elif (Length(ctls) == 1) {
                Adjoint T(ctls[0]);
                Adjoint T(qubit);
                CNOT(ctls[0], qubit);
                T(qubit);
                CNOT(ctls[0], qubit);
            }
            else {
                ApplyWithLessControlsA(Controlled Adjoint S, (ctls, qubit));
            }
        }
    }
}
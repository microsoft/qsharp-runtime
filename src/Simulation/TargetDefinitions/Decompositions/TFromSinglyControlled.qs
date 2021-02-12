// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Intrinsic {

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
        controlled (ctls, ...) {
            if (Length(ctls) == 0) {
                ApplyUncontrolledT(qubit);
            }
            elif (Length(ctls) == 1) {
                R1Frac(1, 3, ctls[0]);
                R1Frac(1, 3, qubit);
                CNOT(ctls[0], qubit);
                Adjoint R1Frac(1, 3, qubit);
                CNOT(ctls[0], qubit);
            }
            else {
                ApplyWithLessControlsA(Controlled T, (ctls, qubit));
            }
        }
    }
}
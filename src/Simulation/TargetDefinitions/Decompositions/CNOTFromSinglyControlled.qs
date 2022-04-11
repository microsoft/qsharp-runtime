// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Intrinsic {

    /// # Summary
    /// Applies the controlled-NOT (CNOT) gate to a pair of qubits.
    ///
    /// # Description
    /// \begin{align}
    ///     \operatorname{CNOT} \mathrel{:=}
    ///     \begin{bmatrix}
    ///         1 & 0 & 0 & 0 \\\\
    ///         0 & 1 & 0 & 0 \\\\
    ///         0 & 0 & 0 & 1 \\\\
    ///         0 & 0 & 1 & 0
    ///     \end{bmatrix},
    /// \end{align}
    ///
    /// where rows and columns are ordered as in the quantum concepts guide.
    ///
    /// # Input
    /// ## control
    /// Control qubit for the CNOT gate.
    /// ## target
    /// Target qubit for the CNOT gate.
    ///
    /// # Remarks
    /// Equivalent to:
    /// ```qsharp
    /// Controlled X([control], target);
    /// ```
    operation CNOT (control : Qubit, target : Qubit) : Unit is Adj + Ctl {
        body (...) {
            ApplyControlledX(control, target);
        }
        controlled (ctls, ...) {
            if Length(ctls) == 0 {
                ApplyControlledX(control, target);
            }
            elif Length(ctls) == 1 {
                CCNOT(ctls[0], control, target);
            }
            elif Length(ctls) == 2 {
                Controlled X([ctls[0], ctls[1], control], target);
            }
            elif Length(ctls) == 3 {
                Controlled X([ctls[0], ctls[1], ctls[2], control], target);
            }
            elif Length(ctls) == 4 {
                Controlled X([ctls[0], ctls[1], ctls[2], ctls[3], control], target);
            }
            elif Length(ctls) == 5 {
                Controlled X([ctls[0], ctls[1], ctls[2], ctls[3], ctls[4], control], target);
            }
            elif Length(ctls) == 6 {
                Controlled X([ctls[0], ctls[1], ctls[2], ctls[3], ctls[4], ctls[5], control], target);
            }
            elif Length(ctls) == 7 {
                Controlled X([ctls[0], ctls[1], ctls[2], ctls[3], ctls[4], ctls[5], ctls[6], control], target);
            }
            elif Length(ctls) == 8 {
                use temp = Qubit();
                within {
                    PhaseCCX(ctls[0], ctls[1], temp);
                }
                apply {
                    Controlled X([temp, ctls[2], ctls[3], ctls[4], ctls[5], ctls[6], ctls[7], control], target);
                }
            }
            else {
                fail "Too many control qubits specified to CNOT gate.";

                // Eventually, we can use recursion via callables with the below utility:
                // ApplyWithLessControlsA(Controlled X, (ctls, qubit));
            }
        }
        adjoint self;
    }
}
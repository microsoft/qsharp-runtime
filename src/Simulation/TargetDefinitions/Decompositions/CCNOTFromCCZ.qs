// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Intrinsic {

    /// # Summary
    /// Applies the doubly controlled–NOT (CCNOT) gate to three qubits.
    ///
    /// # Input
    /// ## control1
    /// First control qubit for the CCNOT gate.
    /// ## control2
    /// Second control qubit for the CCNOT gate.
    /// ## target
    /// Target qubit for the CCNOT gate.
    ///
    /// # Remarks
    /// Equivalent to:
    /// ```qsharp
    /// Controlled X([control1, control2], target);
    /// ```
    operation CCNOT (control1 : Qubit, control2 : Qubit, target : Qubit) : Unit is Adj + Ctl {
        body (...) {
            // [Page 15 of arXiv:1206.0758v3](https://arxiv.org/pdf/1206.0758v3.pdf#page=15)
            within {
                H(target);
            }
            apply {
                CCZ(control1, control2, target);
            }
        }
        controlled (ctls, ...) {
            if Length(ctls) == 0 {
                CCNOT(control1, control2, target);
            }
            elif Length(ctls) == 1 {
                Controlled X([ctls[0], control1, control2], target);
            }
            elif Length(ctls) == 2 {
                Controlled X([ctls[0], ctls[1], control1, control2], target);
            }
            elif Length(ctls) == 3 {
                Controlled X([ctls[0], ctls[1], ctls[2], control1, control2], target);
            }
            elif Length(ctls) == 4 {
                Controlled X([ctls[0], ctls[1], ctls[2], ctls[3], control1, control2], target);
            }
            elif Length(ctls) == 5 {
                Controlled X([ctls[0], ctls[1], ctls[2], ctls[3], ctls[4], control1, control2], target);
            }
            elif Length(ctls) == 6 {
                Controlled X([ctls[0], ctls[1], ctls[2], ctls[3], ctls[4], ctls[5], control1, control2], target);
            }
            elif Length(ctls) == 7 {
                use temp = Qubit();
                within {
                    PhaseCCX(ctls[0], ctls[1], temp);
                }
                apply {
                    Controlled X([temp, ctls[2], ctls[3], ctls[4], ctls[5], ctls[6], control1, control2], target);
                }
            }
            elif Length(ctls) == 8 {
                use temps = Qubit[2];
                within {
                    PhaseCCX(ctls[0], ctls[1], temps[0]);
                    PhaseCCX(ctls[2], ctls[3], temps[1]);
                }
                apply {
                    Controlled X([temps[0], temps[1], ctls[4], ctls[5], ctls[6], ctls[7], control1, control2], target);
                }
            }
            else {
                fail "Too many control qubits specified to CCNOT gate.";

                // Eventually, we can use recursion via callables with the below utility:
                // ApplyWithLessControlsA(Controlled X, (ctls, qubit));
            }
        }
        adjoint self;
    }
}
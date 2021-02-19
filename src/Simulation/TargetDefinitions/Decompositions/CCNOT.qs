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
            Controlled X([control1, control2], target);
        }
        adjoint self;
    }
}
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
            Controlled X([control], target);
        }
        adjoint self;
    }
}
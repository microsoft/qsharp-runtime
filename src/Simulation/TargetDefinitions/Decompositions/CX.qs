// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Canon {
    open Microsoft.Quantum.Intrinsic;

    /// # Summary
    /// Applies the controlled-X (CX) gate to a pair of qubits.
    ///
    /// # Description
    /// This operation can be simulated by the unitary matrix
    /// $$
    /// \begin{align}
    ///     \left(\begin{matrix}
    ///         1 & 0 & 0 & 0 \\\\
    ///         0 & 1 & 0 & 0 \\\\
    ///         0 & 0 & 0 & 1 \\\\
    ///         0 & 0 & 1 & 0
    ///      \end{matrix}\right)
    /// \end{align},
    /// $$
    /// where rows and columns are organized as in the quantum concepts guide.
    ///
    /// # Input
    /// ## control
    /// Control qubit for the CX gate.
    /// ## target
    /// Target qubit for the CX gate.
    ///
    /// # Remarks
    /// Equivalent to:
    /// ```qsharp
    /// Controlled X([control], target);
    /// ```
    /// and to:
    /// ```qsharp
    /// CNOT(control, target);
    /// ```
    operation CX(control : Qubit, target : Qubit) : Unit is Adj + Ctl{
        CNOT(control, target);
    }
}
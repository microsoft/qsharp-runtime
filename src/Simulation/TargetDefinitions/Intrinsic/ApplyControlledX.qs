// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Intrinsic {

    /// # Summary
    /// Applies the controlled-X (or CNOT) gate to a pair of qubits. Does not support 
    /// the Controlled functor.
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
    /// CNOT(control, target);
    /// ```
    internal operation ApplyControlledX (control : Qubit, target : Qubit) : Unit is Adj {
        body intrinsic;
        adjoint self;
    }
}
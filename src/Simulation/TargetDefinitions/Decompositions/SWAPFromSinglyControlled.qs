// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Intrinsic {

    /// # Summary
    /// Applies the SWAP gate to a pair of qubits.
    ///
    /// # Description
    /// \begin{align}
    ///     \operatorname{SWAP} \mathrel{:=}
    ///     \begin{bmatrix}
    ///         1 & 0 & 0 & 0 \\\\
    ///         0 & 0 & 1 & 0 \\\\
    ///         0 & 1 & 0 & 0 \\\\
    ///         0 & 0 & 0 & 1
    ///     \end{bmatrix},
    /// \end{align}
    ///
    /// where rows and columns are ordered as in the quantum concepts guide.
    ///
    /// # Input
    /// ## qubit1
    /// First qubit to be swapped.
    /// ## qubit2
    /// Second qubit to be swapped.
    ///
    /// # Remarks
    /// Equivalent to:
    /// ```qsharp
    /// CNOT(qubit1, qubit2);
    /// CNOT(qubit2, qubit1);
    /// CNOT(qubit1, qubit2);
    /// ```
    operation SWAP (qubit1 : Qubit, qubit2 : Qubit) : Unit is Adj + Ctl {
        body (...) {
            ApplyUncontrolledSWAP(qubit1, qubit2);
        }
        adjoint self;
        controlled (ctls, ...) {
            if (Length(ctls) == 0) {
                ApplyUncontrolledSWAP(qubit1, qubit2);
            }
            else {
                within {
                    CNOT(qubit1, qubit2);
                }
                apply {
                    Controlled CNOT(ctls, (qubit2, qubit1));
                }
            }
        }
    }
}
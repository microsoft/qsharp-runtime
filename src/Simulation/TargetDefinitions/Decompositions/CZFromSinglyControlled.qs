// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Canon {
    open Microsoft.Quantum.Intrinsic;

    /// # Summary
    /// Applies the controlled-Z (CZ) gate to a pair of qubits.
    ///
    /// # Description
    /// This operation can be simulated by the unitary matrix
    /// $$
    /// \begin{align}
    ///     \left(\begin{matrix}
    ///         1 & 0 & 0 & 0 \\\\
    ///         0 & 1 & 0 & 0 \\\\
    ///         0 & 0 & 1 & 0 \\\\
    ///         0 & 0 & 0 & -1
    ///     \end{matrix}\right)
    /// \end{align},
    /// $$
    /// where rows and columns are organized as in the quantum concepts guide.
    ///
    /// # Input
    /// ## control
    /// Control qubit for the CZ gate.
    /// ## target
    /// Target qubit for the CZ gate.
    ///
    /// # Remarks
    /// Equivalent to:
    /// ```qsharp
    /// Controlled Z([control], target);
    /// ```
    operation CZ(control : Qubit, target : Qubit) : Unit {
        body (...) {
            ApplyControlledZ(control, target);
        }
        controlled (ctls, ...) {
            if Length(ctls) == 0 {
                ApplyControlledZ(control, target);
            }
            elif Length(ctls) == 1 {
                CCZ(ctls[0], control, target);
            }
            else {
                use aux = Qubit[Length(ctls) - 1];
                within {
                    CollectControls(ctls, aux, 0);
                    AdjustForSingleControl(ctls, aux);
                }
                apply {
                    CCZ(aux[Length(ctls) - 2], control, target);
                }
            }
        }
        adjoint self;
    }
}

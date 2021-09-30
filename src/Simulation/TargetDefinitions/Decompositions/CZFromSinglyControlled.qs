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
    ///     1 & 0 & 0 & 0 \\\\
    ///     0 & 1 & 0 & 0 \\\\
    ///     0 & 0 & 1 & 0 \\\\
    ///     0 & 0 & 0 & -1
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
                ApplyWithLessControlsA(Controlled CZ, (ctls, (control, target)));
            }
        }
        adjoint self;
    }
}
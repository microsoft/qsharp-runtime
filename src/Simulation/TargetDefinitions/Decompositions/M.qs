// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Intrinsic {

    /// # Summary
    /// Performs a measurement of a single qubit in the
    /// Pauli $Z$ basis.
    ///
    /// # Description
    /// The output result is given by
    /// the distribution
    /// \begin{align}
    ///     \Pr(\texttt{Zero} | \ket{\psi}) =
    ///         \braket{\psi | 0} \braket{0 | \psi}.
    /// \end{align}
    ///
    /// # Input
    /// ## qubit
    /// Qubit to be measured.
    ///
    /// # Output
    /// `Zero` if the $+1$ eigenvalue is observed, and `One` if
    /// the $-1$ eigenvalue is observed.
    ///
    /// # Remarks
    /// Equivalent to:
    /// ```qsharp
    /// Measure([PauliZ], [qubit]);
    /// ```
    operation M (qubit : Qubit) : Result {
        return Measure([PauliZ], [qubit]);
    }
}
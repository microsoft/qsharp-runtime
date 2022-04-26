// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Intrinsic {
    open Microsoft.Quantum.Measurement;

    /// # Summary
    /// Performs a joint measurement of one or more qubits in the
    /// specified Pauli bases.
    ///
    /// # Description
    /// The output result is given by the distribution:
    /// \begin{align}
    ///     \Pr(\texttt{Zero} | \ket{\psi}) =
    ///         \frac12 \braket{
    ///             \psi \mid|
    ///             \left(
    ///                 \boldone + P_0 \otimes P_1 \otimes \cdots \otimes P_{N-1}
    ///             \right) \mid|
    ///             \psi
    ///         },
    /// \end{align}
    /// where $P_i$ is the $i$th element of `bases`, and where
    /// $N = \texttt{Length}(\texttt{bases})$.
    /// That is, measurement returns a `Result` $d$ such that the eigenvalue of the
    /// observed measurement effect is $(-1)^d$.
    ///
    /// # Input
    /// ## bases
    /// Array of single-qubit Pauli values indicating the tensor product
    /// factors on each qubit.
    /// ## qubits
    /// Register of qubits to be measured.
    ///
    /// # Output
    /// `Zero` if the $+1$ eigenvalue is observed, and `One` if
    /// the $-1$ eigenvalue is observed.
    ///
    /// # Remarks
    /// If the basis array and qubit array are different lengths, then the
    /// operation will fail.
    operation Measure (bases : Pauli[], qubits : Qubit[]) : Result {
        if Length(bases) != Length(qubits) {
            fail "Arrays 'bases' and 'qubits' must be of the same length.";
        }
        if Length(bases) == 1 {
            MapPauli(qubits[0], PauliZ, bases[0]);
            let res = MZ(qubits[0]);
            Adjoint MapPauli(qubits[0], PauliZ, bases[0]);
            return res;
        }
        else {
            return JointMeasure(bases, qubits);
        }
    }
}
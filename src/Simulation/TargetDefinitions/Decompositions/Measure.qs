// Copyright (c) Microsoft Corporation. All rights reserved.
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
        if (Length(bases) != Length(qubits)) { fail "Arrays 'bases' and 'qubits' must be of the same length."; }
        if Length(bases) == 0 {
            return Zero;
        }
        elif Length(bases) == 1 {
            MapPauli(qubits[0], PauliZ, bases[0]);
            let res = MZ(qubits[0]);
            Adjoint MapPauli(qubits[0], PauliZ, bases[0]);
            return res;
        }
        elif Length(bases) == 2 {
            use q = Qubit();
            within {
                H(q);
            }
            apply {
                JointMeasureHelper(bases[0], q, qubits[0]);
                JointMeasureHelper(bases[1], q, qubits[1]);
            }
            return MResetZ(q);
        }
        elif Length(bases) == 3 {
            use q = Qubit();
            within {
                H(q);
            }
            apply {
                JointMeasureHelper(bases[0], q, qubits[0]);
                JointMeasureHelper(bases[1], q, qubits[1]);
                JointMeasureHelper(bases[2], q, qubits[2]);
            }
            return MResetZ(q);
        }
        elif Length(bases) == 4 {
            use q = Qubit();
            within {
                H(q);
            }
            apply {
                JointMeasureHelper(bases[0], q, qubits[0]);
                JointMeasureHelper(bases[1], q, qubits[1]);
                JointMeasureHelper(bases[2], q, qubits[2]);
                JointMeasureHelper(bases[3], q, qubits[3]);
            }
            return MResetZ(q);
        }
        elif Length(bases) == 5 {
            use q = Qubit();
            within {
                H(q);
            }
            apply {
                JointMeasureHelper(bases[0], q, qubits[0]);
                JointMeasureHelper(bases[1], q, qubits[1]);
                JointMeasureHelper(bases[2], q, qubits[2]);
                JointMeasureHelper(bases[3], q, qubits[3]);
                JointMeasureHelper(bases[4], q, qubits[4]);
            }
            return MResetZ(q);
        }
        elif Length(bases) == 6 {
            use q = Qubit();
            within {
                H(q);
            }
            apply {
                JointMeasureHelper(bases[0], q, qubits[0]);
                JointMeasureHelper(bases[1], q, qubits[1]);
                JointMeasureHelper(bases[2], q, qubits[2]);
                JointMeasureHelper(bases[3], q, qubits[3]);
                JointMeasureHelper(bases[4], q, qubits[4]);
                JointMeasureHelper(bases[5], q, qubits[5]);
            }
            return MResetZ(q);
        }
        elif Length(bases) == 7 {
            use q = Qubit();
            within {
                H(q);
            }
            apply {
                JointMeasureHelper(bases[0], q, qubits[0]);
                JointMeasureHelper(bases[1], q, qubits[1]);
                JointMeasureHelper(bases[2], q, qubits[2]);
                JointMeasureHelper(bases[3], q, qubits[3]);
                JointMeasureHelper(bases[4], q, qubits[4]);
                JointMeasureHelper(bases[5], q, qubits[5]);
                JointMeasureHelper(bases[6], q, qubits[6]);
            }
            return MResetZ(q);
        }
        elif Length(bases) == 8 {
            use q = Qubit();
            within {
                H(q);
            }
            apply {
                JointMeasureHelper(bases[0], q, qubits[0]);
                JointMeasureHelper(bases[1], q, qubits[1]);
                JointMeasureHelper(bases[2], q, qubits[2]);
                JointMeasureHelper(bases[3], q, qubits[3]);
                JointMeasureHelper(bases[4], q, qubits[4]);
                JointMeasureHelper(bases[5], q, qubits[5]);
                JointMeasureHelper(bases[6], q, qubits[6]);
                JointMeasureHelper(bases[7], q, qubits[7]);
            }
            return MResetZ(q);
        }
        else {
            fail "Too many qubits specified in call to Measure.";
        }
    }
}
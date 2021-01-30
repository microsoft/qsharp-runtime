// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Intrinsic {

    /// # Summary
    /// Applies the exponential of a multi-qubit Pauli operator.
    ///
    /// # Description
    /// \begin{align}
    ///     e^{i \theta [P_0 \otimes P_1 \cdots P_{N-1}]},
    /// \end{align}
    /// where $P_i$ is the $i$th element of `paulis`, and where
    /// $N = $`Length(paulis)`.
    ///
    /// # Input
    /// ## paulis
    /// Array of single-qubit Pauli values indicating the tensor product
    /// factors on each qubit.
    /// ## theta
    /// Angle about the given multi-qubit Pauli operator by which the
    /// target register is to be rotated.
    /// ## qubits
    /// Register to apply the given rotation to.
    operation Exp (paulis : Pauli[], theta : Double, qubits : Qubit[]) : Unit is Adj + Ctl {
        body (...) {
            if (Length(paulis) != Length(qubits)) { fail "Arrays 'pauli' and 'qubits' must have the same length"; }
            let (newPaulis, newQubits) = RemovePauliI(paulis, qubits);

            if (Length(newPaulis) != 0) {
                ExpUtil(newPaulis, theta , newQubits, R(_, -2.0 * theta, _));
            }
            else {
                ApplyGlobalPhase(theta);
            }
        }
        adjoint(...) {
            Exp(paulis, -theta, qubits);
        }
    }
}
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Intrinsic {
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Convert;

    /// # Summary
    /// Applies the exponential of a multi-qubit Pauli operator
    /// with an argument given by a dyadic fraction.
    ///
    /// # Description
    /// \begin{align}
    ///     e^{i \pi k [P_0 \otimes P_1 \cdots P_{N-1}] / 2^n},
    /// \end{align}
    /// where $P_i$ is the $i$th element of `paulis`, and where
    /// $N = $`Length(paulis)`.
    ///
    /// # Input
    /// ## paulis
    /// Array of single-qubit Pauli values indicating the tensor product
    /// factors on each qubit.
    /// ## numerator
    /// Numerator ($k$) in the dyadic fraction representation of the angle
    /// by which the qubit register is to be rotated.
    /// ## power
    /// Power of two ($n$) specifying the denominator of the angle by which
    /// the qubit register is to be rotated.
    /// ## qubits
    /// Register to apply the given rotation to.
    operation ExpFrac (paulis : Pauli[], numerator : Int, power : Int, qubits : Qubit[]) : Unit is Adj + Ctl {
        body (...) {
            if (Length(paulis) != Length(qubits)) { fail "Arrays 'pauli' and 'target' must have the same length"; }

            if (Length(paulis) != 0) {
                let indices = IndicesOfNonIdentity(paulis);
                let newPaulis = Subarray(indices, paulis);
                let newQubits = Subarray(indices, qubits);

                if (Length(indices) != 0) {
                    let (kModPositive, n) = ReducedDyadicFractionPeriodic(numerator, power); // k is odd, in the range [1,2*2^n-1] or (k,n) are both 0
                    let numeratorD = PI() * IntAsDouble(kModPositive);
                    let theta = numeratorD * PowD(2.0, IntAsDouble(-n));
                    ExpUtil(newPaulis, theta, newQubits, RFrac(_, numerator, power, _));
                }
                else {
                    ApplyGlobalPhaseFracWithR1Frac(numerator, power);
                }
            }
        }
        adjoint(...) {
            ExpFrac(paulis, -numerator, power, qubits);
        }
    }
}
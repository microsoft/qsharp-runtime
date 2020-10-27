// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Intrinsic {
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Diagnostics;

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
    @EnableTestingViaName("Test.TargetDefinitions.ExpFrac")
    operation ExpFrac (paulis : Pauli[], numerator : Int, power : Int, qubits : Qubit[]) : Unit is Adj + Ctl {
        let angle = (PI() * IntAsDouble(numerator)) / (2.0 ^ IntAsDouble(power));
        Exp(paulis, angle, qubits);
    }
}
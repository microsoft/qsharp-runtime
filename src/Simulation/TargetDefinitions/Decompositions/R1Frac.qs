// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Intrinsic {

    /// # Summary
    /// Applies a rotation about the $\ket{1}$ state by an angle specified
    /// as a dyadic fraction.
    ///
    /// # Description
    /// \begin{align}
    ///     R_1(n, k) \mathrel{:=}
    ///     \operatorname{diag}(1, e^{i \pi k / 2^n}).
    /// \end{align}
    ///
    /// > [!WARNING]
    /// > This operation uses the **opposite** sign convention from
    /// > @"microsoft.quantum.intrinsic.r", and does not include the
    /// > factor of $1/ 2$ included by @"microsoft.quantum.intrinsic.r1".
    ///
    /// # Input
    /// ## numerator
    /// Numerator in the dyadic fraction representation of the angle
    /// by which the qubit is to be rotated.
    /// ## power
    /// Power of two specifying the denominator of the angle by which
    /// the qubit is to be rotated.
    /// ## qubit
    /// Qubit to which the gate should be applied.
    ///
    /// # Remarks
    /// Equivalent to:
    /// ```qsharp
    /// RFrac(PauliZ, -numerator, denominator + 1, qubit);
    /// RFrac(PauliI, numerator, denominator + 1, qubit);
    /// ```
    operation R1Frac (numerator : Int, power : Int, qubit : Qubit) : Unit is Adj + Ctl {
        RFrac(PauliZ, -numerator, power + 1, qubit);
        RFrac(PauliI, numerator, power + 1, qubit);
    }
}
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Intrinsic {
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Diagnostics;

    /// # Summary
    /// Applies a rotation about the given Pauli axis by an angle specified
    /// as a dyadic fraction.
    ///
    /// # Description
    /// \begin{align}
    ///     R_{\mu}(n, k) \mathrel{:=}
    ///     e^{i \pi n \sigma_{\mu} / 2^k},
    /// \end{align}
    /// where $\mu \in \{I, X, Y, Z\}$.
    ///
    /// > [!WARNING]
    /// > This operation uses the **opposite** sign convention from
    /// > @"microsoft.quantum.intrinsic.r".
    ///
    /// # Input
    /// ## pauli
    /// Pauli operator to be exponentiated to form the rotation.
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
    /// // PI() is a Q# function that returns an approximation of π.
    /// R(pauli, -PI() * IntAsDouble(numerator) / IntAsDouble(2 ^ (power - 1)), qubit);
    /// ```
    @EnableTestingViaName("Test.TargetDefinitions.RFrac")
    operation RFrac (pauli : Pauli, numerator : Int, power : Int, qubit : Qubit) : Unit is Adj + Ctl {
        let angle = ((-2.0 * PI()) * IntAsDouble(numerator)) / IntAsDouble(2 ^ power);
        R(pauli, angle, qubit);
    }
}
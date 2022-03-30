// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Intrinsic {
    open Microsoft.Quantum.Targeting;

    /// # Summary
    /// Applies the square root of the Pauli $X$ gate. Note that the Controlled functor is not supported.
    ///
    /// # Description
    /// \begin{align}
    ///     \sqrt{\sigma_x} \mathrel{:=}
    ///     \frac{12}
    ///     \begin{bmatrix}
    ///         1 + i & 1 - i \\\\
    ///         1 - i & 1 + i
    ///     \end{bmatrix}.
    /// \end{align}
    ///
    /// # Input
    /// ## qubit
    /// Qubit to which the gate should be applied.
    @TargetInstruction("sqrtx__body")
    internal operation ApplyUncontrolledSqrtX (qubit : Qubit) : Unit {
        body intrinsic;
    }
}
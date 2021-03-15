// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Intrinsic {

    /// # Summary
    /// Applies a rotation about the $\ket{1}$ state by a given angle.
    ///
    /// # Description
    /// \begin{align}
    ///     R_1(\theta) \mathrel{:=}
    ///     \operatorname{diag}(1, e^{i\theta}).
    /// \end{align}
    ///
    /// # Input
    /// ## theta
    /// Angle about which the qubit is to be rotated.
    /// ## qubit
    /// Qubit to which the gate should be applied.
    ///
    /// # Remarks
    /// Equivalent to:
    /// ```qsharp
    /// R(PauliZ, theta, qubit);
    /// R(PauliI, -theta, qubit);
    /// ```
    operation R1 (theta : Double, qubit : Qubit) : Unit is Adj + Ctl {
        R(PauliZ, theta, qubit);
        R(PauliI, -theta, qubit);
    }
}
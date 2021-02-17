// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Intrinsic {

    /// # Summary
    /// Applies a rotation about the $y$-axis by a given angle. Note that the Controlled
    /// functor is not supported.
    ///
    /// # Description
    /// \begin{align}
    ///     R_y(\theta) \mathrel{:=}
    ///     e^{-i \theta \sigma_y / 2} = 
    ///     \begin{bmatrix}
    ///         \cos \frac{\theta}{2} & -\sin \frac{\theta}{2}  \\\\
    ///         \sin \frac{\theta}{2} & \cos \frac{\theta}{2}
    ///     \end{bmatrix}.
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
    /// R(PauliY, theta, qubit);
    /// ```
    internal operation ApplyUncontrolledRy (theta : Double, qubit : Qubit) : Unit is Adj {
        body intrinsic;
    }
}
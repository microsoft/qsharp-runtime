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
        body (...) {
            Rz(theta, qubit);
        }
        controlled (ctls, ...) {
            if Length(ctls) == 0 {
                Rz(theta, qubit);
            }
            elif Length(ctls) == 1 {
                CR1(theta, ctls[0], qubit);
            }
            else {
                use aux = Qubit[Length(ctls) - 1];
                within {
                    CollectControls(ctls, aux);
                    AdjustForSingleControl(ctls, aux);
                }
                apply {
                    CR1(theta, aux[Length(ctls) - 2], qubit);
                }
            }
        }
    }

    internal operation CR1(theta : Double, control : Qubit, target : Qubit) : Unit is Adj {
        Rz(theta/2.0, target);
        Rz(theta/2.0, control);
        CNOT(control,target);
        Rz(-theta/2.0, target);
        CNOT(control,target);
    }

}
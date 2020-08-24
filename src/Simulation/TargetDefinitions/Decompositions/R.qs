// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Intrinsic {
    open Microsoft.Quantum.Diagnostics;

    /// # Summary
    /// Applies a rotation about the given Pauli axis.
    ///
    /// # Description
    /// \begin{align}
    ///     R_{\mu}(\theta) \mathrel{:=}
    ///     e^{-i \theta \sigma_{\mu} / 2},
    /// \end{align}
    /// where $\mu \in \{I, X, Y, Z\}$.
    ///
    /// # Input
    /// ## pauli
    /// Pauli operator ($\mu$) to be exponentiated to form the rotation.
    /// ## theta
    /// Angle about which the qubit is to be rotated.
    /// ## qubit
    /// Qubit to which the gate should be applied.
    ///
    /// # Remarks
    /// When called with `pauli = PauliI`, this operation applies
    /// a *global phase*. This phase can be significant
    /// when used with the `Controlled` functor.
    @EnableTestingViaName("Test.TargetDefinitions.R")
    operation R (pauli : Pauli, theta : Double, qubit : Qubit) : Unit is Adj + Ctl {
        if( pauli != PauliI ) {
            if( pauli == PauliX ) {
                Rx(theta, qubit);
            }
            elif( pauli == PauliY ) {
                Ry(theta, qubit);
            }
            else { // PauliZ
                Rz(theta, qubit);
            }
        }
        else {
            RotationAngleValidation(theta);
            ApplyGlobalPhase( - theta / 2.0 );
        }
    }
}
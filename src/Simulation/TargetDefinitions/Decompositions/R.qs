// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Intrinsic {

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
    /// Angle in radians about which the qubit is to be rotated.
    /// ## qubit
    /// Qubit to which the gate should be applied.
    ///
    /// # Remarks
    /// When called with `pauli = PauliI`, this operation applies
    /// a *global phase*. This phase can be significant
    /// when used with the `Controlled` functor.
    operation R (pauli : Pauli, theta : Double, qubit : Qubit) : Unit is Adj + Ctl {
        if (pauli == PauliX) {
            Rx(theta, qubit);
        }
        elif (pauli == PauliY) {
            Ry(theta, qubit);
        }
        elif (pauli == PauliZ) {
            Rz(theta, qubit);
        }
        else { // PauliI
            ApplyGlobalPhase( - theta / 2.0 );
        }
    }

    internal operation ApplyGlobalPhase (theta : Double) : Unit is Ctl + Adj {
        body (...) {}
        controlled (ctls, (...)) {
            if (Length(ctls) > 0) {
                let qubit = ctls[0];
                let rest = ctls[1...];
                // Invoke Controlled R1, which will recursively call back into ApplyGlobalPhase.
                // Each time the ctls array is one shorter, until it is empty and the recursion stops.
                Controlled R1(rest, (theta, qubit));
            }
        }
    }

}

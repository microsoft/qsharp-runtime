// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Intrinsic {

    /// # Summary
    /// Given an array of qubits, measure them and ensure they are in the |0⟩ state
    /// such that they can be safely released.
    ///
    /// # Input
    /// ## qubits
    /// An array of qubits whose states are to be reset to $\ket{0}$.
    operation ResetAll (qubits : Qubit[]) : Unit {
        for qubit in qubits {
            Reset(qubit);
        }
    }
}
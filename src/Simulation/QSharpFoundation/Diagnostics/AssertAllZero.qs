// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.


namespace Microsoft.Quantum.Diagnostics {
    open Microsoft.Quantum.Intrinsic;

    /// # Summary
    /// Assert that given qubits are all in $\ket{0}$ state.
    ///
    /// # Input
    /// ## qubits
    /// Qubits that are asserted to be in $\ket{0}$ state.
    ///
    /// # See Also
    /// - AssertQubit
    operation AssertAllZero (qubits : Qubit[]) : Unit is Adj + Ctl{
        body (...) {
            for qubit in qubits {
                AssertQubit(Zero, qubit);
            }
        }

        adjoint self;
        controlled (ctrls, ...) {
            AssertAllZero(qubits);
        }
        controlled adjoint self;
    }

    /// # Summary
    /// Assert that given qubits are all in $\ket{0}$ state up to a given tolerance.
    ///
    /// # Input
    /// ## qubits
    /// Qubits that are asserted to be in $\ket{0}$ state.
    /// ## tolerance
    /// Accuracy with which the state should be in $\ket{0}$ state
    ///
    /// # See Also
    /// - AssertQubitWithinTolerance
    operation AssertAllZeroWithinTolerance(qubits : Qubit[], tolerance : Double) : Unit is Adj + Ctl{

        body (...) {
            for qubit in qubits {
                AssertQubitWithinTolerance(Zero, qubit, tolerance);
            }
        }

        adjoint self;

        controlled (ctrls, ...) {
            AssertAllZeroWithinTolerance(qubits, tolerance);
        }
    }

}



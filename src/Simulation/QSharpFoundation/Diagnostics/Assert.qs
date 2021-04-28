// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Diagnostics {  
    /// # Summary
    /// Asserts that measuring the given qubits in the given Pauli basis will
    /// always have the given result.
    ///
    /// # Input
    /// ## bases
    /// A measurement effect to assert the probability of, expressed as a
    /// multi-qubit Pauli operator.
    /// ## qubits
    /// A register on which to make the assertion.
    /// ## result
    /// The expected result of `Measure(bases, qubits)`.
    /// ## msg
    /// A message to be reported if the assertion fails.
    ///
    /// # Remarks
    /// Note that the Adjoint and Controlled versions of this operation will not
    /// check the condition.
    ///
    /// # See Also
    /// - Microsoft.Quantum.Diagnostics.AssertMeasurementProbability
    operation AssertMeasurement(bases : Pauli[], qubits : Qubit[], result : Result, msg : String) : Unit
    is Adj + Ctl {
        body (...) {
            AssertMeasurementProbability(bases, qubits, result, 1.0, msg, 1e-10);
        }
        adjoint (...) {
            // Empty.
        }
        controlled (controllingQubits, ...) {
            // Empty.
        }
    }
    
    
    /// # Summary
    /// Asserts that measuring the given qubits in the given Pauli basis will have the given result
    /// with the given probability, within some tolerance.
    ///
    /// # Input
    /// ## bases
    /// A measurement effect to assert the probability of, expressed as a
    /// multi-qubit Pauli operator.
    /// ## qubits
    /// A register on which to make the assertion.
    /// ## result
    /// An expected result of `Measure(bases, qubits)`.
    /// ## prob
    /// The probability with which the given result is expected.
    /// ## msg
    /// A message to be reported if the assertion fails.
    ///
    /// # Example
    /// ```qsharp
    /// using (register = Qubit()) {
    ///     H(register);
    ///     AssertProb([PauliZ], [register], One, 0.5,
    ///         "Measuring in conjugate basis did not give 50/50 results.", 1e-5);
    /// }
    /// ```
    ///
    /// # Remarks
    /// Note that the Adjoint and Controlled versions of this operation will not
    /// check the condition.
    ///
    /// # See Also
    /// - Microsoft.Quantum.Diagnostics.AssertMeasurement
    operation AssertMeasurementProbability(bases : Pauli[], qubits : Qubit[], result : Result, prob : Double, msg : String, tol : Double) : Unit
    is Adj + Ctl {
        body intrinsic;
    }

}

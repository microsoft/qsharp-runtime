// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Intrinsic {
    @Deprecated("Microsoft.Quantum.Diagnostics.AssertMeasurement")
    operation Assert (bases : Pauli[], qubits : Qubit[], result : Result, msg : String) : Unit
    is Adj + Ctl {
        Microsoft.Quantum.Diagnostics.AssertMeasurement(bases, qubits, result, msg);
    }
    
    @Deprecated("Microsoft.Quantum.Diagnostics.AssertMeasurementProbability")
    operation AssertProb (bases : Pauli[], qubits : Qubit[], result : Result, prob : Double, msg : String, tol : Double) : Unit
    is Adj + Ctl {
        Microsoft.Quantum.Diagnostics.AssertMeasurementProbability(bases, qubits, result, prob, msg, tol);
    }
}
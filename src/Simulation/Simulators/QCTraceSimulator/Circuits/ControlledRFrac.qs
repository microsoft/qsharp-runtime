// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators.Circuits
{
    
    /// # Summary
    /// ControlledR is exp( iφ|1⟩⟨1|⊗P) on qubits 1 and 2
    /// 
    /// # Input
    /// ## pauli
    /// φ
    /// ## numerator
    /// P
    /// ## control
    /// qubit 1, the rotation is applied when this qubit is in state |1⟩ 
    /// ## target
    /// qubit 2, the rotation is applied to this qubit
    operation ControlledRFrac (pauli : Pauli, numerator : Int, power : Int, control : Qubit, target : Qubit) : Unit
    is Adj {
        if (pauli != PauliI)
        {
            PauliZFlip(pauli, target);
            ControlledRZFrac(numerator, power, control, target);
            Adjoint PauliZFlip(pauli, target);
        }
        else
        {
            InternalRFrac(PauliZ, -numerator, power + 1, control);
        }
    }
    
}



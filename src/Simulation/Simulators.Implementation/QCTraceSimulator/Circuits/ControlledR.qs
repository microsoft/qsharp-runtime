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
    /// ## angle
    /// P
    /// ## control
    /// qubit 1, the rotation is applied when this qubit is in state |1⟩
    /// ## target
    /// qubit 2, the rotation is applied to this qubit
    operation ControlledR (pauli : Pauli, angle : Double, control : Qubit, target : Qubit) : Unit
    is Adj {
        if (pauli != PauliI)
        {
            PauliZFlip(pauli, target);
            ControlledRZ(angle, control, target);
            Adjoint PauliZFlip(pauli, target);
        }
        else
        {
            InternalRz(-angle / 2.0, control);
        }
    }
    
}



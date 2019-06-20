namespace Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators.Circuits
{
    
    /// <summary> ControlledR is exp( iφ|1⟩⟨1|⊗P) on qubits 1 and 2 </summary>
    /// <param name="angle"> φ </param>
    /// <param name="pauli"> P </param>
    /// <param name="control"> qubit 1, the rotation is applied when this qubit is in state |1⟩ </param>
    /// <param name="target"> qubit 2, the rotation is applied to this qubit </param>
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



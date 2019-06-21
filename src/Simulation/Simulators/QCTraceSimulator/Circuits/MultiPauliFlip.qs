namespace Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators.Circuits
{
    
    /// <summary> Applies Clifford that maps Zₖ to P₁ ⊗ … ⊗ Pₙ by conjugation </summary>
    /// <param name = "paulis">  P₁ , … , Pₙ </param>
    /// <param name = "k"> k above, number of qubit in array of target qubits on which Z operator acts </param>
    /// <param name = "target"> Qubits to which apply the Clifford </param>
    operation MultiPauliFlip (paulis : Pauli[], target : Qubit[], k : Int) : Unit
    is Adj
    {
        FailOn(Length(paulis) != Length(target), $"paulis and target array must have the same length");
        FailOn(paulis[k] == PauliI, $"paulis[k] must not be equal to PauliI");
            
        for (j in 0 .. Length(paulis) - 1)
        {
            if (paulis[j] != PauliI)
            {
                PauliZFlip(paulis[j], target[j]);
            }
        }
            
        for (j in 0 .. Length(paulis) - 1)
        {
            if (j != k and paulis[j] != PauliI)
            {
                InternalCX(target[j], target[k]);
            }
        }
    }
    
}



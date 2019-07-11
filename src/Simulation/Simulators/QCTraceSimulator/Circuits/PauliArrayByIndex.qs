// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators.Circuits
{
    
    /// <summary> Creates a new array
    /// of the form [ paulies[i] : i ∈ indices ]
    /// </summary>
    function PauliArrayByIndex (paulies : Pauli[], indices : Int[]) : Pauli[]
    {
        mutable result = new Pauli[Length(indices)];
        
        for (i in 0 .. Length(indices) - 1)
        {
            set result = result w/ i <- paulies[indices[i]];
        }
        
        return result;
    }
    
}



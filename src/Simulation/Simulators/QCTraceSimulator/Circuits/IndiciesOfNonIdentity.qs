// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators.Circuits
{
    
    /// # Summary
    /// Returns array of indices of paulies that are
    /// not equal to PauliI
    function IndicesOfNonIdentity (paulies : Pauli[]) : Int[]
    {
        mutable nonIdPauliCount = 0;
        
        for (i in 0 .. Length(paulies) - 1)
        {
            if (paulies[i] != PauliI)
            {
                set nonIdPauliCount = nonIdPauliCount + 1;
            }
        }
        
        mutable indices = new Int[nonIdPauliCount];
        mutable index = 0;
        
        for (i in 0 .. Length(paulies) - 1)
        {
            if (paulies[i] != PauliI)
            {
                set indices = indices w/ index <- i;
                set index = index + 1;
            }
        }
        
        return indices;
    }
    
}



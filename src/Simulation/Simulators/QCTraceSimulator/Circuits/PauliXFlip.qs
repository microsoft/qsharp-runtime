// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators.Circuits
{
    
    /// # Summary
    /// Applies a Clifford unitary that maps by conjugation Pauli X
    /// to Pauli given by 'basis' argument. The unitary is applied to the qubit given by 'target' argument
    operation PauliXFlip (basis : Pauli, target : Qubit) : Unit
    is Adj {

        FailOn(basis == PauliI, $"Pauli X cannot be mapped to identity using conjugation by Clifford");
            
        if (basis == PauliZ)
        {
            InternalH(target);
        }
        elif (basis == PauliY)
        {
            Adjoint InternalS(target);
        }
        else
        {
            FailOn(basis != PauliX, $"the remaining case must be PauliX");
        }
    }
    
}



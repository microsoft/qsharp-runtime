// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators.Circuits
{

    /// # Summary
    /// Applies a Clifford unitary that maps by conjugation Pauli Z
    /// to Pauli given by 'basis' argument. The unitary is applied to the qubit given by 'target' argument
    operation PauliZFlip (basis : Pauli, target : Qubit) : Unit
    is Adj {

        FailOn(basis == PauliI, $"PauliX cannot be mapped to PauliI using conjugation by Clifford");
            
        if (basis == PauliX)
        {
            InternalH(target);
        }
        elif (basis == PauliY)
        {
            Adjoint InternalHY(target);
        }
        else
        {
            FailOn(basis != PauliZ, $"PauliZ must be the only remaining case");
        }
    }
    
}



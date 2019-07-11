// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators.Circuits
{
    
    /// #Summary
    /// Controlled Z operation
    ///
    /// #Remark
    /// Controlled  Z is symmetric, so there is no need to call one qubit control and another target
    operation CZ (a : Qubit, b : Qubit) : Unit
    {
        body (...)
        {
            PauliXFlip(PauliZ, b);
            InternalCX(a, b);
            Adjoint PauliXFlip(PauliZ, b);
        }
        
        adjoint self;
    }
    
}



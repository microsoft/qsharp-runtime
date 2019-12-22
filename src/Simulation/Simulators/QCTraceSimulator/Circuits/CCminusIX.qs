// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators.Circuits
{
    
    /// # Summary
    /// Controlled-controlled -iX
    operation CCminusIX (control1 : Qubit, control2 : Qubit, target : Qubit) : Unit
    is Adj {
        PauliZFlip(PauliX, target);
        CCminusIZ(control1, control2, target);
        Adjoint PauliZFlip(PauliX, target);
    }
    
}



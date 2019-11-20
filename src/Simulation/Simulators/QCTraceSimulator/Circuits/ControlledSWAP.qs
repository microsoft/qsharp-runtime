// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators.Circuits
{
    
    /// # Remarks
    /// We use a usual identity SWAP = C₁X₂ C₂X₁ C₁X₂ and control the middle gate
    operation ControlledSWAP (control : Qubit, target1 : Qubit, target2 : Qubit) : Unit
    is Adj {

        InternalCX(target2, target1);
        CCX(control, target1, target2);
        InternalCX(target2, target1);
    }
    
}



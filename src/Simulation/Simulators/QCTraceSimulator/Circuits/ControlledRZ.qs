// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators.Circuits
{
    
    /// # Summary
    /// ControlledRZ is exp( iφ|1⟩⟨1|⊗Z)
    /// 
    /// # Input
    /// ## angle
    /// φ
    /// ## control
    /// first qubit operation acts on
    /// ## target
    /// second qubit operation acts on
    operation ControlledRZ (angle : Double, control : Qubit, target : Qubit) : Unit
    is Adj {
        InternalRz(angle / 2.0, target);
        ExpZZ(angle / 4.0, target, control);
    }
    
}



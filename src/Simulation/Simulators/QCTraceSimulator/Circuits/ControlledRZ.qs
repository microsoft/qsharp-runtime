// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators.Circuits
{
    
    /// <summary> ControlledRZ is exp( iφ|1⟩⟨1|⊗Z) </summary>
    /// <param name = "angle"> φ </param>
    /// <param name="control"> first qubit operation acts on </param>
    /// <param name="target"> second qubit operation acts on </param>
    /// <remarks>
    /// exp( iφ|1⟩⟨1|⊗Z) = exp( iφ/2|11⟩⟨11| - iφ/2|10⟩⟨10| ) = exp( -iφ/2(I-Z)/2⊗( |0⟩⟨0| - |1⟩⟨1| ) =
    /// = exp( -iφ/2 (I-Z)/2⊗Z )
    /// = exp( -iφ/2² I⊗Z) exp(iφ/2² Z⊗Z) </remarks>
    operation ControlledRZ (angle : Double, control : Qubit, target : Qubit) : Unit
    is Adj {
        InternalRz(angle / 2.0, target);
        ExpZZ(angle / 4.0, target, control);
    }
    
}



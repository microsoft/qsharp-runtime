// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators.Circuits
{    
    /// # Summary
    /// ControlledR1 is  exp( iφ|11⟩⟨11| )
    /// 
    /// # Input
    /// ## angle
    /// φ
    /// 
    /// # Remarks
    /// exp( iφ|11⟩⟨11| ) = exp( iφ (I-Z)/2⊗(I-Z)/2 ) =
    /// = exp( iφ/2² I⊗I) exp(-iφ/2² I⊗Z) exp(-iφ/2² Z⊗I) exp(iφ/2² Z⊗Z)
    operation ControlledR1 (angle : Double, a : Qubit, b : Qubit) : Unit
    is Adj {
        //  ExpI( angle/4, target ); Don't need global phase because there is no controlled version of this operation
        InternalRz(angle / 2.0, a);
        InternalRz(angle / 2.0, b);
        ExpZZ(angle / 4.0, a, b);
    }
    
}



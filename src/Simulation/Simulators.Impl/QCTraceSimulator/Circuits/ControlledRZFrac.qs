// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators.Circuits
{
    
	/// # Summary
    /// ControlledRZFrac is exp( i πk/2ⁿ|1⟩⟨1|⊗Z)
    /// 
    /// # Input
    /// ## numerator
    /// k
    /// ## power
    /// n
    /// ## control
    /// first qubit operation acts on
    /// ## target
    /// second qubit operation acts on
    /// 
    /// # Remarks
    /// exp( i πk/2ⁿ|1⟩⟨1|⊗Z) = exp( iπk/2ⁿ(I-Z)/2⊗Z ) =
    /// = exp( iπk/2ⁿ (I-Z)/2⊗Z )
    /// = exp( iπk/2ⁿ⁺¹ I⊗Z) exp( -iπk/2ⁿ⁺¹ Z⊗Z)
    operation ControlledRZFrac (numerator : Int, power : Int, control : Qubit, target : Qubit) : Unit
    is Adj {

        let (num_reduced, power_reduced) = ReducedForm(numerator, power);
            
        if (power_reduced == 3)
        {
            //we want to express ControlledRZFrac in terms of Controlled-T in this case
            // exp( i πk/2ⁿ|1⟩⟨1|⊗Z ) = exp( i πk/2ⁿ|1⟩⟨1|⊗(I-2|1⟩⟨1|) ) =
            // exp( i πk/2ⁿ|1⟩⟨1|⊗I ) exp( -iπk/2ⁿ⁻¹|1⟩⟨1|⊗|1⟩⟨1|) )
            // this is exp( i πk/2ⁿ|1⟩⟨1|⊗I )
            InternalRzFrac(-num_reduced, power_reduced + 1, control);
                
            // when n=2, we get exp(-iπk/2³⁻¹|1⟩⟨1|) = T⁻ᵏ
            // this is exp( -iπk/2ⁿ⁻¹|1⟩⟨1|⊗|1⟩⟨1| )
            ControlledTPower(-num_reduced, target, control);
        }
        elif (power_reduced == 1)
        {
            InternalRzFrac(-num_reduced, power_reduced + 1, control);
            CZ(control, target);
        }
        elif (power_reduced <= 0)
        {
            InternalRzFrac(-num_reduced, power_reduced + 1, control);
        }
        else
        {
            InternalRzFrac(numerator, power + 1, target);
            ExpFracZZ(-numerator, power + 1, control, target);
        }
    }
    
}



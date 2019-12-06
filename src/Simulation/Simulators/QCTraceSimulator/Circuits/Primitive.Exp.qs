// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators.Circuits
{
    
    operation ExpNoId (pauli : Pauli[], angle : Double, target : Qubit[]) : Unit
    is Adj
    {
        body (...)
        {
            FailOn(Length(pauli) == 0, $"Length of Pauli array should be at least 1");
            FailOn(Length(pauli) != Length(target), $"pauli and target must be of the same length");
            MultiPauliFlip(pauli, target, 0);
            R(PauliZ, -2.0 * angle, target[0]);
            Adjoint MultiPauliFlip(pauli, target, 0);
        }
                
        controlled (ctrls, ...)
        {
            FailOn(Length(pauli) == 0, $"Length of Pauli array should be at least 1");
            FailOn(Length(pauli) != Length(target), $"pauli and target must be of the same length");
            MultiPauliFlip(pauli, target, 0);
            Controlled R(ctrls, (PauliZ, -2.0 * angle, target[0]));
            Adjoint MultiPauliFlip(pauli, target, 0);
        }        
    }
    
    /// # Summary
    /// Performs exp( i φ P₁ ⊗ … ⊗ Pₙ )
    /// 
    /// # Input
    /// ## pauli
    /// P₁,...,Pₙ
    /// ## angle
    /// φ
    /// ## target
    /// Array of qubits on which exponent acts
    operation Exp (pauli : Pauli[], angle : Double, target : Qubit[]) : Unit
    is Adj + Ctl
    {
        FailOn(Length(pauli) != Length(target), $"Arrays 'pauli' and 'target' must have the same length");
            
        if (Length(pauli) != 0)
        {
            let indices = IndicesOfNonIdentity(pauli);
            let newPauli = PauliArrayByIndex(pauli, indices);
                
            if (Length(indices) != 0)
            {
                let op = ExpNoId(newPauli, angle, _);
                ApplyByIndexAdjointableControllable(op, indices, target);
            }
            else
            {
                // It does not matter on which quibit we apply global phase
                R(PauliI, -2.0 * angle, target[0]);
            }
        }
    }
    
}



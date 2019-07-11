// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators.Circuits
{
    
    operation ExpNoIdFrac (pauli : Pauli[], numerator : Int, power : Int, target : Qubit[]) : Unit
    is Adj
    {
        body (...)
        {
            FailOn(Length(pauli) == 0, $"Length of pauli array should be at least 1");
            FailOn(Length(pauli) != Length(target), $"pauli and target must be of the same length");
            MultiPauliFlip(pauli, target, 0);
            RFrac(PauliZ, numerator, power, target[0]);
            Adjoint MultiPauliFlip(pauli, target, 0);
        }
                
        controlled (ctrls, ...)
        {
            FailOn(Length(pauli) == 0, $"Length of pauli array should be at least 1");
            FailOn(Length(pauli) != Length(target), $"pauli and target must be of the same length");
            MultiPauliFlip(pauli, target, 0);
            Controlled RFrac(ctrls, (PauliZ, numerator, power, target[0]));
            Adjoint MultiPauliFlip(pauli, target, 0);
        }
    }
    
    
    operation ExpFrac (pauli : Pauli[], numerator : Int, power : Int, target : Qubit[]) : Unit
    is Adj + Ctl
    {
        FailOn(Length(pauli) != Length(target), $"Arrays 'pauli' and 'target' must have the same length");
            
        if (Length(pauli) != 0)
        {
            let indices = IndicesOfNonIdentity(pauli);
            let newPauli = PauliArrayByIndex(pauli, indices);
                
            if (Length(indices) != 0)
            {
                ApplyByIndexAdjointableControllable(ExpNoIdFrac(newPauli, numerator, power, _), indices, target);
            }
            else
            {
                RFrac(PauliI, numerator, power, target[0]);
            }
        }
    }
    
}



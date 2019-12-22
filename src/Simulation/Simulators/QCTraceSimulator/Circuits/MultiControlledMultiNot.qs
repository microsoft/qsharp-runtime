// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators.Circuits
{
    
    operation MultiControlledMultiNot (controls : Qubit[], targets : Qubit[]) : Unit
    is Adj {

        FailOn(Length(controls) < 2, $"function is defined for 2 or more controls");
            
        using (ands = Qubit[Length(controls) - 1])
        {
            AndLadder(controls, ands);
            MultiCX(ands[Length(ands) - 1], targets);
            Adjoint AndLadder(controls, ands);
        }
    }
    
}



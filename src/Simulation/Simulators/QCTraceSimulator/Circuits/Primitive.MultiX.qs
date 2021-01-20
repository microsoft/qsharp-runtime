// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators.Circuits
{
    
    operation MultiX (targets : Qubit[]) : Unit
    is Adj + Ctl {

        body (...)
        {
            for (i in 0 .. Length(targets) - 1)
            {
                InternalPauli(PauliX, targets[i]);
            }
        }
        
        controlled (ctrls, ...)
        {
            if (Length(ctrls) == 0)
            {
                MultiX(targets);
            }
            elif (Length(ctrls) == 1)
            {
                for (i in 0 .. Length(targets) - 1)
                {
                    InternalCX(ctrls[0], targets[i]);
                }
            }
            else
            {
                MultiControlledMultiNot(ctrls, targets);
            }
        }
    }
    
}



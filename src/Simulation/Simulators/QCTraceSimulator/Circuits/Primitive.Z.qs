// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators.Circuits
{
    
    operation Z (target : Qubit) : Unit
    is Adj + Ctl {

        body (...)
        {
            InternalPauli(PauliZ, target);
        }
        
        controlled (ctrls, ...)
        {
            if (Length(ctrls) == 0)
            {
                InternalPauli(PauliZ, target);
            }
            else
            {
                if (Length(ctrls) == 1)
                {
                    CZ(ctrls[0], target);
                }
                else
                {
                    if (Length(ctrls) == 2)
                    {
                        CCZ(ctrls[0], ctrls[1], target);
                    }
                    else
                    {
                        PauliXFlip(PauliZ, target);
                        MultiControlledUTwoTargets(CCX, ctrls[1 .. Length(ctrls) - 1], ctrls[0], target);
                        Adjoint PauliXFlip(PauliZ, target);
                    }
                }
            }
        }
    }
    
}



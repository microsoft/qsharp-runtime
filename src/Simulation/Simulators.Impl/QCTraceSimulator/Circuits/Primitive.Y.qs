// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators.Circuits
{
    
    operation Y (target : Qubit) : Unit
    is Adj + Ctl {

        body (...)
        {
            InternalPauli(PauliY, target);
        }
        
        controlled (ctrls, ...)
        {
            if (Length(ctrls) == 0)
            {
                InternalPauli(PauliY, target);
            }
            else
            {
                PauliXFlip(PauliY, target);
                
                if (Length(ctrls) == 1)
                {
                    InternalCX(ctrls[0], target);
                }
                else
                {
                    if (Length(ctrls) == 2)
                    {
                        CCX(ctrls[0], ctrls[1], target);
                    }
                    else
                    {
                        MultiControlledUTwoTargets(CCX, ctrls[1 .. Length(ctrls) - 1], ctrls[0], target);
                    }
                }
                
                Adjoint PauliXFlip(PauliY, target);
            }
        }
    }
    
}



// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators.Circuits
{
    
    operation CCNOT (control1 : Qubit, control2 : Qubit, target : Qubit) : Unit
    is Adj + Ctl {

        body (...)
        {
            CCX(control1, control2, target);
        }
                
        controlled (ctrls, ...)
        {
            if (Length(ctrls) == 0)
            {
                CCX(control1, control2, target);
            }
            else
            {
                MultiControlledUTwoTargets(CCX, ctrls + [control1], control2, target);
            }
        }
    }
    
}



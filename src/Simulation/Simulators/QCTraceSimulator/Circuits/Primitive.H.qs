// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators.Circuits
{
    
    operation H (target : Qubit) : Unit
    is Adj + Ctl {

        body (...)
        {
            InternalH(target);
        }
        
        controlled (ctrls, ...)
        {
            MultiControlledFromOpAndSinglyCtrldOp(InternalH, ControlledH, ctrls, target);
        }
    }
    
}



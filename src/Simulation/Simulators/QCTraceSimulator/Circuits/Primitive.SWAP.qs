// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators.Circuits
{
    
    operation InternalSWAP (target1 : Qubit, target2 : Qubit) : Unit
    is Adj {

        InternalCX(target1, target2);
        InternalCX(target2, target1);
        InternalCX(target1, target2);
    }
    
    
    operation SWAP (target1 : Qubit, target2 : Qubit) : Unit
    is Adj + Ctl {

        body (...)
        {
            InternalSWAP(target1, target2);
        }
        
        controlled (ctrls, ...)
        {
            MultiControlledFromOpAndSinglyCtrldOp2(InternalSWAP, ControlledSWAP, ctrls, target1, target2);
        }
    }
    
}



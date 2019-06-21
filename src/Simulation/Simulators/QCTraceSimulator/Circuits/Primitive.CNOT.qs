// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators.Circuits
{
    
    operation CNOT (control : Qubit, target : Qubit) : Unit
    is Adj + Ctl {

        body (...)
        {
            InternalCX(control, target);
        }
        
        controlled (ctrls, ...)
        {
            MultiControlledFromOpAndSinglyCtrldOp2(InternalCX, CCX, ctrls, control, target);
        }
    }
    
}



// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators.Circuits
{
    
    operation R1 (angle : Double, target : Qubit) : Unit
    is Adj {

        body (...)
        {
            InternalR(PauliZ, angle, target);
        }
        
        controlled (ctrls, ...)
        {
            let op = InternalR(PauliZ, angle, _);
            let cOp = ControlledR1(angle, _, _);
            MultiControlledFromOpAndSinglyCtrldOp(op, cOp, ctrls, target);
        }
    }
    
}



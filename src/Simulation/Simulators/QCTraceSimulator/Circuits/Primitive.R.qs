// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators.Circuits
{
    
    operation R (pauli : Pauli, angle : Double, target : Qubit) : Unit
    is Adj + Ctl {

        body (...)
        {
            InternalR(pauli, angle, target);
        }
        
        controlled (ctrls, ...)
        {
            let op = R(pauli, angle, _);
            let cOp = ControlledR(pauli, angle, _, _);
            MultiControlledFromOpAndSinglyCtrldOp(op, cOp, ctrls, target);
        }
    }
    
}



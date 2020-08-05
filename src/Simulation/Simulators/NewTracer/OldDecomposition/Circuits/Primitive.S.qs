// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.Simulators.NewTracer.OldDecomposition.Circuits
{
    
    operation S (target : Qubit) : Unit
    is Adj + Ctl {

        body (...)
        {
            InternalS(target);
        }
        
        controlled (ctrls, ...)
        {
            let ControlledS = ControlledR1Frac(1, 1, _, _);
            MultiControlledFromOpAndSinglyCtrldOp(InternalS, ControlledS, ctrls, target);
        }
    }
    
}



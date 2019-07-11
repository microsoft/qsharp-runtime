// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators.Circuits
{
    
    operation R1Frac (numerator : Int, denominatorPower : Int, target : Qubit) : Unit
    is Adj + Ctl {

        body (...)
        {
            InternalRFrac(PauliZ, -numerator, denominatorPower + 1, target);
        }
        
        controlled (ctrls, ...)
        {
            let rfrac = InternalRFrac(PauliZ, -numerator, denominatorPower + 1, _);
            let crfrac = ControlledR1Frac(numerator, denominatorPower, _, _);
            MultiControlledFromOpAndSinglyCtrldOp(rfrac, crfrac, ctrls, target);
        }
    }
    
}



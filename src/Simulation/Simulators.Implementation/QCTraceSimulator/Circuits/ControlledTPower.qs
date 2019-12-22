// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators.Circuits
{
    
    /// # Summary
    /// Power of Controlled T gate
    /// 
    /// # Input
    /// ## power
    /// power of T gate being controlled. Must be odd
    operation ControlledTPower (power : Int, target : Qubit, control : Qubit) : Unit
    is Adj {

        FailOn(power % 2 == 0, $"function is not implemented for even powers");
        let powerMod8 = Mod(power, 8);
            
        if (powerMod8 == 1)
        {
            ControlledT(control, target);
        }
        elif (powerMod8 == 7)
        {
            Adjoint ControlledT(control, target);
        }
        elif (powerMod8 == 3)
        {
            ControlledTS(control, target);
        }
        else
        {
            FailOn(powerMod8 != 5, $"the only remaining option is 5");
            Adjoint ControlledTS(control, target);
        }
    }    
}



// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators.Circuits
{

    operation ControlledR1Frac (numerator : Int, power : Int, control : Qubit, target : Qubit) : Unit
    {
        body (...)
        {
            let (num_reduced, power_reduced) = ReducedForm(numerator, power);
            
            // odd power of T gate
            if (power_reduced == 2)
            {
                ControlledTPower(num_reduced, control, target);
            }
            else
            {
                //odd power of Z
                if (power_reduced == 0)
                {
                    if (num_reduced != 0)
                    {
                        CZ(control, target);
                    }
                }
                else
                {
                    if (power_reduced > 0)
                    {
                        // RFrac( PauliI, numerator, n+2 , target )
                        InternalRzFrac(-num_reduced, power_reduced + 2, target);
                        InternalRzFrac(-num_reduced, power_reduced + 2, control);
                        ExpFracZZ(num_reduced, power_reduced + 2, target, control);
                    }
                    // when power is negative we have an identity operator
                }
            }
        }
        
        adjoint (...)
        {
            ControlledR1Frac(-numerator, power, control, target);
        }
    }
    
}



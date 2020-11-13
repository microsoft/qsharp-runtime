// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators.Circuits
{
    
    /// #Summary
    /// $ket{x_1, \dots ,x_n} $ket{y_1, \dots ,y_n} \mapsto 
    /// $ket{x_1, \dots ,x_n} $ket{y_1 \osum (x_1 \land x_2 ), \dots , y_{n-1} \osum ( x_a \land x_2 \land \dots \land x_n)}
    /// 
    /// #Input
    /// ##controls
    /// $ket{x_1, \dots ,x_n} 
    /// ##targets
    /// $ket{y_1, \dots ,y_n} 
    operation AndLadder (controls : Qubit[], targets : Qubit[]) : Unit
    is Adj {

        FailOn(Length(controls) != Length(targets) + 1, $"Length(controls) must be equal to Length(target) + 1");
        FailOn(Length(controls) < 2, $"function is underfined for less then 2 controls");
        CCX(controls[0], controls[1], targets[0]);
            
        for (k in 1 .. Length(targets) - 1)
        {
            CCX(controls[k + 1], targets[k - 1], targets[k]);
        }
    }
    
}



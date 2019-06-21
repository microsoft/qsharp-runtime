// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators.Circuits
{
    
    operation Ry (angle : Double, target : Qubit) : Unit
    is Adj + Ctl {

        R(PauliY, angle, target);
    }
    
}



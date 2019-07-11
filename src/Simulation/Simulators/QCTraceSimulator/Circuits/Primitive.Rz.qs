// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators.Circuits
{
    
    operation Rz (angle : Double, target : Qubit) : Unit
    is Adj + Ctl {

        R(PauliZ, angle, target);
    }
    
}



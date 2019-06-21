// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators.Circuits
{
    
    operation CCminusIZ (control1 : Qubit, control2 : Qubit, target : Qubit) : Unit
    is Adj {

        InternalRzFrac(1, 3, target);
        ExpFracZZ(-1, 3, target, control1);
        ExpFracZZ(-1, 3, target, control2);
        ExpFracZZZ(1, 3, target, control1, control2);
    }
    
}



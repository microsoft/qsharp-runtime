// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators.Circuits {
    internal operation IsingZZ (theta : Double, qubit0 : Qubit, qubit1 : Qubit) : Unit is Adj + Ctl {
        Exp([PauliZ, PauliZ], theta * 2.0, [qubit0, qubit1]);
    }
}
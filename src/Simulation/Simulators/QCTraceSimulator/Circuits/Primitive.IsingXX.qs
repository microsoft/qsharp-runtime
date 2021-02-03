// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators.Circuits {
    internal operation IsingXX (theta : Double, qubit0 : Qubit, qubit1 : Qubit) : Unit is Adj + Ctl {
        Exp([PauliX, PauliX], theta * 2.0, [qubit0, qubit1]);
    }
}
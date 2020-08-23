// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.Simulators.Tests {
    open Microsoft.Quantum.Diagnostics;

    operation DumpToFile(filename : String) : Unit {
        DumpMachine<String>(filename);
    }

}
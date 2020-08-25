// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.Simulators.Tests.Circuits
{
    open Microsoft.Quantum.Intrinsic;

    operation SliceGenerationTest() : Unit {
        using (qs = Qubit[4]) {
            PrepareCatState(qs);
            if (M(qs[0]) == One) {
                for (target in qs) {
                    X(target);
                }
            }
        }
    }

    operation PrepareCatState(register : Qubit[]) : Unit is Adj + Ctl {
        H(register[0]);
        for (target in register[1...]) {
            CNOT(register[0], target);
        }
    }
}

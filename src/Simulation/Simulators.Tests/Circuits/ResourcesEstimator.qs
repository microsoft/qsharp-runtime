// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.Simulators.Tests
{
    open Microsoft.Quantum.Intrinsic;

    operation VerySimpleEstimate () : Unit
    {
        using(q = Qubit[3]) {
            X(q[0]);
            H(q[1]);

            Controlled X([q[1]], q[0]);

            ResetAll([q[1], q[0]]);
        }
    }

    // This operation has to choose between optimizing depth
    // or width of the cirquit.
    operation DepthVersusWidth () : Unit
    {
        using(q = Qubit()) {
            T(q);
        }
        using(q = Qubit()) {
            T(q);
        }
    }
}

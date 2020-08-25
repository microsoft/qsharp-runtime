﻿// Copyright (c) Microsoft Corporation. All rights reserved.
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

    // When multiple operations are traced by resource estimator,
    // it should report cumulative statistics in the end.
    operation Operation_1_of_2() : Unit
    {
        using ((a, b) = (Qubit(), Qubit())) {
            H(a);
            CNOT(a, b);
            T(b);
        }
    }
    operation Operation_2_of_2() : Result
    {
        using ((a, b, c) = (Qubit(), Qubit(), Qubit())) {
            X(a);
            CNOT(a, b);
            Rx(0.42, b);
            CNOT(b, c);
            return M(c);
        }
    }

    // Tests for Depth and Width lower bounds
    operation DepthDifferentQubits () : Unit
    {
        using(q = Qubit[3]) {
            T(q[0]);
            T(q[1]);
            T(q[2]);
            T(q[0]);
        }
    }
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

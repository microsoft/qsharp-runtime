// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.Simulators.Tests.Circuits
{
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Diagnostics;

    operation ConditionalExpressionTest() : Unit {
        using (q = Qubit()) {
            AssertQubit(Zero, q);

            mutable flag = false;
            (flag ? X | I)(q);
            AssertQubit(Zero, q);

            set flag = true;
            (flag ? X | I)(q);
            AssertQubit(One, q);

            Reset(q);
        }
    }
}
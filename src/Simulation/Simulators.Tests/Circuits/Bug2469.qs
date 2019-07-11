// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.Simulators.Tests.Circuits
{
    open Microsoft.Quantum.Intrinsic;

    operation TestSafeToRunCliffords (flag : Bool) : Unit 
    {
        using (q = Qubit())
        {
            X(q);
            if (flag)
            {
                Y(q);
                Z(q);
                H(q);
                S(q);
            }
            X(q);  // So that it's safe to release
        }
    }
}

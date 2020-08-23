// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Bug2248 {
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Diagnostics;
    

    operation TestDumpMachineDoesntChangeState (N : Int) : Unit 
    {
        using (qs = Qubit[N])
        {
            for (q in qs) 
            {
                X(q);
                DumpMachine("");
                AssertQubit(One, q);
                Reset(q);
            }
        }
    }
}

namespace Microsoft.Quantum.Simulation.Simulators.Tests.Circuits
{
    open Bug2248;

    operation Bug2248Test () : Unit
    {
        for(i in 1..4) 
        {
            TestDumpMachineDoesntChangeState(i);
        }
    }
}
 
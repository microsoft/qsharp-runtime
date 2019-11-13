// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Issue76
{
    open Microsoft.Quantum.Intrinsic;

    function BuggyReturn<'T> (param: 'T): Bool {
        return true;
    }

    function AssertBuggyReturn<'T> (param: 'T): Unit {
        if (not BuggyReturn<'T>(param)) {
            Message("BuggyReturn returned false");
        }
    }
}

namespace Microsoft.Quantum.Simulation.Simulators.Tests.Circuits
{
    open Issue76;
    open Microsoft.Quantum.Intrinsic;

    function BuggyReturnTest () : Unit
    {
        AssertBuggyReturn<Int>(0); 
        if (not BuggyReturn<Int>(0)) { 
            Message("BuggyReturn returned false");
        }
    }
}

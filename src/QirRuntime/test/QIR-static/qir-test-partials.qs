// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Testing.QIR
{
    open Microsoft.Quantum.Intrinsic;

    function Subtract(from : Int, what : Int) : Int
    {
        return from - what;
    }

    @EntryPoint()
    function TestPartials(x : Int, y : Int) : Int
    {
        let subtractor = Subtract(x, _);
        return subtractor(y);
    }
}

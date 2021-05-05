// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Testing.QIR {
    function Subtract(from : Int, what : Int) : Int {
        return from - what;
    }

    @EntryPoint()
    function TestPartials(x : Int, y : Int) : Int {
        let subtractor = Subtract(x, _);
        return subtractor(y);
    }
}

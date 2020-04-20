// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.CsharpGeneration.Testing.EntryPoint {
    @EntryPoint()
    operation ReturnUnit() : Unit { }
}

// ---

namespace Microsoft.Quantum.CsharpGeneration.Testing.EntryPoint {
    @EntryPoint()
    operation ReturnInt() : Int {
        return 42;
    }
}

// ---

namespace Microsoft.Quantum.CsharpGeneration.Testing.EntryPoint {
    @EntryPoint()
    operation ReturnString() : String {
        return "Hello, World!";
    }
}

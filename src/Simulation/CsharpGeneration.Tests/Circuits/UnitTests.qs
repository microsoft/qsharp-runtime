// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Core {
    @Attribute ()
    newtype Attribute = Unit;

    @Attribute ()
    newtype TestOperation = String;
}

namespace Microsoft.Quantum.Tests.UnitTests {
    
    open Microsoft.Quantum.Core;

    @TestOperation("QuantumSimulator")
    operation UnitTest1 () : Unit {
    }
    
}



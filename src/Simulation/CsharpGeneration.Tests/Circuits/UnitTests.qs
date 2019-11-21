// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Core {

    @Attribute()
    newtype Attribute = Unit;
}

namespace Microsoft.Quantum.Diagnostics {

    @Attribute()
    newtype TestOperation = String;
}

namespace Microsoft.Quantum.Tests.UnitTests {
    
    open Microsoft.Quantum.Diagnostics;

    @TestOperation("QuantumSimulator")
    @TestOperation("ToffoliSimulator")
    operation UnitTest1 () : Unit {
    }
    
}



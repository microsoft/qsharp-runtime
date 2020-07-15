// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.Simulators.Tests.Circuits {
    
    newtype FooUDT = (String, (Qubit, Double));

    operation FooUDTOp (foo : FooUDT) : Unit is Ctl + Adj { }
    
}

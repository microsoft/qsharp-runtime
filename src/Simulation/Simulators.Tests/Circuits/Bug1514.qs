// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Bug1514 {

    operation Bug1514() : Unit {
        Foo();
        Bar(3);
    }

    operation Foo() : Unit {
    }

    function Bar<'T>(a: 'T) : Unit {
    }
}

namespace Microsoft.Quantum.Simulation.Simulators.Tests.Circuits
{
    open Bug1514;

    operation Bug1514Test () : Unit
    {
        Bug1514();
    }
}
 
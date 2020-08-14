namespace Microsoft.Quantum.Simulation.Simulators.Tests.Circuits {
    open Microsoft.Quantum.Diagnostics;

    operation Body() : Unit { }

    operation AdjointBody() : Unit is Adj { }

    operation ControlledBody() : Unit is Ctl { }

    operation ControlledAdjointBody() : Unit is Adj + Ctl { }

    operation Init() : Unit { }

    operation __dataIn() : Unit { }

    operation __dataOut() : Unit { }

    @Test("QuantumSimulator")
    operation CSharpMembers() : Unit {
        Body();
        AdjointBody();
        ControlledBody();
        ControlledAdjointBody();
        Init();
        __dataIn();
        __dataOut();
        FooBar.Baz();
        Foo.Bar.Baz();
    }
}

namespace FooBar {
    function Baz() : Unit { }
}

namespace Foo.Bar {
    function Baz() : Unit { }
}

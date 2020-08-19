namespace Microsoft.Quantum.Simulation.Simulators.Tests.Circuits.MemberNames {
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Simulation.Simulators.Tests.Circuits;

    newtype Foo = (Foo : Int);

    newtype Items = (Item2 : Int, Item1 : Int);

    // TODO:
    // newtype Bar = (Data : Int);

    operation Body() : Unit { }

    operation AdjointBody() : Unit is Adj { }

    operation ControlledBody() : Unit is Ctl { }

    operation ControlledAdjointBody() : Unit is Adj + Ctl { }

    operation Init() : Unit { }

    operation Run() : Unit { }

    operation Info() : Unit { }

    @Test("QuantumSimulator")
    operation SupportsReservedOperationNames() : Unit {
        Body();
        AdjointBody();
        ControlledBody();
        ControlledAdjointBody();
        Init();
        Run();
        Info();
    }

    @Test("QuantumSimulator")
    operation SupportsConfusingQualifiedNames() : Unit {
        FooBar.Baz();
        Foo.Bar.Baz();
    }

    @Test("QuantumSimulator")
    operation SupportsReservedNamedItems() : Unit {
        let foo = Foo(7);
        AssertEqual(7, foo::Foo);

        let items = Items(3, 4);
        AssertEqual(3, items::Item2);
        AssertEqual(4, items::Item1);

        // TODO:
        // let bar = Bar(10);
        // AssertEqual(10, bar::Data);
    }
}

namespace FooBar {
    function Baz() : Unit { }
}

namespace Foo.Bar {
    function Baz() : Unit { }
}

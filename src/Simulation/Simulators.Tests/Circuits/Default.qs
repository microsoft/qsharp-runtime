namespace Microsoft.Quantum.Simulation.Simulators.Tests.Circuits.Default {
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Simulation.Simulators.Tests.Circuits;

    @Test("QuantumSimulator")
    function DefaultUnit() : Unit {
        AssertEqual((), Default<Unit>());
    }

    @Test("QuantumSimulator")
    function DefaultInt() : Unit {
        AssertEqual(0, Default<Int>());
    }

    @Test("QuantumSimulator")
    function DefaultBigInt() : Unit {
        AssertEqual(0L, Default<BigInt>());
    }

    @Test("QuantumSimulator")
    function DefaultDouble() : Unit {
        AssertEqual(0.0, Default<Double>());
    }

    @Test("QuantumSimulator")
    function DefaultBool() : Unit {
        AssertEqual(false, Default<Bool>());
    }

    @Test("QuantumSimulator")
    function DefaultString() : Unit {
        AssertEqual("", Default<String>());
    }

    // @Test("QuantumSimulator")
    // function DefaultQubit() : Unit {
    //     AssertEqual(???, Default<Qubit>());
    // }

    @Test("QuantumSimulator")
    function DefaultPauli() : Unit {
        AssertEqual(PauliI, Default<Pauli>());
    }

    @Test("QuantumSimulator")
    function DefaultResult() : Unit {
        AssertEqual(Zero, Default<Result>());
    }

    @Test("QuantumSimulator")
    function DefaultRange() : Unit {
        AssertEqual(1..1..0, Default<Range>());
    }

    // @Test("QuantumSimulator")
    // function DefaultCallable() : Unit {
    //     AssertEqual(???, Default<(Unit -> Unit)>());
    // }

    @Test("QuantumSimulator")
    function DefaultArray() : Unit {
        AssertEqual(new Unit[0], Default<Unit[]>());
    }

    @Test("QuantumSimulator")
    function DefaultTuple() : Unit {
        AssertEqual((false, 0), Default<(Bool, Int)>());
        AssertEqual((0, Zero, ""), Default<(Int, Result, String)>());
        AssertEqual(("", "", "", ""), Default<(String, String, String, String)>());
        AssertEqual(("", "", "", "", ""), Default<(String, String, String, String, String)>());
        AssertEqual(("", "", "", "", "", ""), Default<(String, String, String, String, String, String)>());
        AssertEqual(("", "", "", "", "", "", ""), Default<(String, String, String, String, String, String, String)>());
        AssertEqual(("", "", "", "", "", "", "", ""), Default<(String, String, String, String, String, String, String, String)>());
        AssertEqual(("", "", "", "", "", "", "", "", ""), Default<(String, String, String, String, String, String, String, String, String)>());
    }

    newtype BoolInt = (Bool, Int);
    newtype IntResultString = (Int, Result, String);

    @Test("QuantumSimulator")
    function DefaultUserDefinedType() : Unit {
        AssertEqual(BoolInt(false, 0), Default<BoolInt>());
        AssertEqual(IntResultString(0, Zero, ""), Default<IntResultString>());
    }
}

﻿namespace Microsoft.Quantum.Simulation.Simulators.Tests.Circuits.Default {
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Simulation.Simulators.Tests.Circuits;

    @Test("QuantumSimulator")
    @Test("SparseSimulator")
    function DefaultUnit() : Unit {
        AssertEqual((), Default<Unit>());
    }

    @Test("QuantumSimulator")
    @Test("SparseSimulator")
    function DefaultInt() : Unit {
        AssertEqual(0, Default<Int>());
    }

    @Test("QuantumSimulator")
    @Test("SparseSimulator")
    function DefaultBigInt() : Unit {
        AssertEqual(0L, Default<BigInt>());
    }

    @Test("QuantumSimulator")
    @Test("SparseSimulator")
    function DefaultDouble() : Unit {
        AssertEqual(0.0, Default<Double>());
    }

    @Test("QuantumSimulator")
    @Test("SparseSimulator")
    function DefaultBool() : Unit {
        AssertEqual(false, Default<Bool>());
    }

    @Test("QuantumSimulator")
    @Test("SparseSimulator")
    function DefaultString() : Unit {
        AssertEqual("", Default<String>());
    }

    @Test("QuantumSimulator")
    @Test("SparseSimulator")
    function DefaultQubit() : Unit {
        // Creating a default qubit (without using it) should succeed.
        let _ = Default<Qubit>();
    }

    @Test("QuantumSimulator")
    @Test("SparseSimulator")
    function DefaultPauli() : Unit {
        AssertEqual(PauliI, Default<Pauli>());
    }

    @Test("QuantumSimulator")
    @Test("SparseSimulator")
    function DefaultResult() : Unit {
        AssertEqual(Zero, Default<Result>());
    }

    @Test("QuantumSimulator")
    @Test("SparseSimulator")
    function DefaultRange() : Unit {
        let range = Default<Range>();
        AssertEqual(1, RangeStart(range));
        AssertEqual(1, RangeStep(range));
        AssertEqual(0, RangeEnd(range));
    }

    @Test("QuantumSimulator")
    @Test("SparseSimulator")
    function DefaultCallable() : Unit {
        // Creating a default callable (without calling it) should succeed.
        let _ = Default<(Unit -> Unit)>();
    }

    @Test("QuantumSimulator")
    @Test("SparseSimulator")
    function DefaultArray() : Unit {
        AssertEqual(new Unit[0], Default<Unit[]>());
    }

    @Test("QuantumSimulator")
    @Test("SparseSimulator")
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
    @Test("SparseSimulator")
    function DefaultUserDefinedType() : Unit {
        AssertEqual(BoolInt(false, 0), Default<BoolInt>());
        AssertEqual(IntResultString(0, Zero, ""), Default<IntResultString>());
        AssertEqual((BoolInt(false, 0), IntResultString(0, Zero, "")), Default<(BoolInt, IntResultString)>());
    }
}

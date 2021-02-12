namespace Microsoft.Quantum.AutoEmulation.Testing {
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Measurement;

    @EmulateWith("Microsoft.Quantum.Intrinsic.SWAP", "ToffoliSimulator")
    operation QuantumSwap(a : Qubit, b : Qubit) : Unit {
        within {
            CNOT(a, b);
            H(a);
            H(b);
        } apply {
            CNOT(a, b);
        }
    }

    @Test("ToffoliSimulator")
    operation TestQuantumSwap() : Unit {
        use a = Qubit();
        use b = Qubit();

        X(a);

        QuantumSwap(a, b);

        EqualityFactR(MResetZ(a), Zero, "unexpected value for a after swap");
        EqualityFactR(MResetZ(b), One, "unexpected value for b after swap");
    }
}

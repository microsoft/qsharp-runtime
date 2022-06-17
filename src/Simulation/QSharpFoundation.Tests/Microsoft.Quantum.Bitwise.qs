namespace Quantum.QSharpFoundation.Tests {
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Bitwise;

    @Test("SparseSimulator")
    operation TestParity() : Unit {
        Fact(Parity(-1) == 0, "Expected 0.");
    }
}

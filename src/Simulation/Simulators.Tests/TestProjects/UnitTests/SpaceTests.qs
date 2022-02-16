namespace Microsoft.Quantum.Testing.SpacesInFileName {
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Testing;

    @Test("QuantumSimulator")
    @Test("SparseSimulator")
    function LibraryWithSpacesTest() : Unit {
        FactS("Hello quantum world!", LibraryWithSpaces.HelloQ());
    }
}

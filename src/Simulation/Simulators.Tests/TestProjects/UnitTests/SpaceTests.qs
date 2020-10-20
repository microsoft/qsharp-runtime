namespace Microsoft.Quantum.Testing.SpacesInFileName {
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Testing;

    @Test("QuantumSimulator")
    function LibraryWithSpacesTest() : Unit {
        FactS("Hello quantum world!", LibraryWithSpaces.HelloQ());
    }
}

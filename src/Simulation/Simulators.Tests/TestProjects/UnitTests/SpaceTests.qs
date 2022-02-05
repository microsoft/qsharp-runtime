namespace Microsoft.Quantum.Testing.SpacesInFileName {
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Testing;

    @Test("QuantumSimulator")
    @Test("Microsoft.Quantum.Simulation.Simulators.SparseSimulator")
    function LibraryWithSpacesTest() : Unit {
        FactS("Hello quantum world!", LibraryWithSpaces.HelloQ());
    }
}

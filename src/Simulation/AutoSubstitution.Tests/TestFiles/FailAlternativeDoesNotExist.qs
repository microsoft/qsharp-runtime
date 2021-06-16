namespace AutoSubstitutionTests {
    open Microsoft.Quantum.Targeting;

    @SubstitutableOnTarget("Namespace.NotExisting", "ToffoliSimulator")
    operation Fail() : Unit {}
}

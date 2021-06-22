namespace AutoSubstitutionTests {
    open Microsoft.Quantum.Targeting;

    @SubstitutableOnTarget("FailClassical", "ToffoliSimulator")
    operation Fail() : Unit {}

    operation FailClassical() : Unit {}
}

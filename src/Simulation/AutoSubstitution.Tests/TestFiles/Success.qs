namespace AutoSubstitutionTests {
    open Microsoft.Quantum.Targeting;

    @SubstitutableOnTarget("AutoSubstitutionTests.SuccessClassical", "ToffoliSimulator")
    operation Success() : Unit {}

    operation SuccessClassical() : Unit {}
}

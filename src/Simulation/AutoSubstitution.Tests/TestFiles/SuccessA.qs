namespace AutoSubstitutionTests {
    open Microsoft.Quantum.Targeting;

    @SubstitutableOnTarget("AutoSubstitutionTests.SuccessClassical", "ToffoliSimulator")
    operation Success() : Unit is Adj {}

    operation SuccessClassical() : Unit is Adj {}
}

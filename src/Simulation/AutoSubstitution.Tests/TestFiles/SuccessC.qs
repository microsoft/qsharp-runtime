namespace AutoSubstitutionTests {
    open Microsoft.Quantum.Targeting;

    @SubstitutableOnTarget("AutoSubstitutionTests.SuccessClassical", "ToffoliSimulator")
    operation Success() : Unit is Ctl {}

    operation SuccessClassical() : Unit is Ctl {}
}

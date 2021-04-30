namespace AutoSubstitutionTests {
    open Microsoft.Quantum.Targeting;

    @SubstitutableOnTarget("AutoSubstitutionTests.FailClassical", "ToffoliSimulator")
    operation Fail(a : Int) : Unit {}

    operation FailClassical(a : Double) : Unit {}
}

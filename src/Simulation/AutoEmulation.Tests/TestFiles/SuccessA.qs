namespace AutoEmulationTests {
    open Microsoft.Quantum.Targeting;

    @SubstitutableOnTarget("AutoEmulationTests.SuccessClassical", "ToffoliSimulator")
    operation Success() : Unit is Adj {}

    operation SuccessClassical() : Unit is Adj {}
}

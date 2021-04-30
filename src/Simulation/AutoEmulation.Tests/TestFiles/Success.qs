namespace AutoEmulationTests {
    open Microsoft.Quantum.Targeting;

    @SubstitutableOnTarget("AutoEmulationTests.SuccessClassical", "ToffoliSimulator")
    operation Success() : Unit {}

    operation SuccessClassical() : Unit {}
}

namespace AutoEmulationTests {
    open Microsoft.Quantum.Targeting;

    @SubstitutableOnTarget("AutoEmulationTests.SuccessClassical", "ToffoliSimulator")
    operation Success() : Unit is Ctl {}

    operation SuccessClassical() : Unit is Ctl {}
}

namespace AutoEmulationTests {
    open Microsoft.Quantum.Targeting;

    @SubstitutableOnTarget("AutoEmulationTests.FailClassical", "ToffoliSimulator")
    operation Fail(a : Int) : Unit {}

    operation FailClassical(a : Double) : Unit {}
}

namespace AutoEmulationTests {
    open Microsoft.Quantum.Targeting;

    @SubstitutableOnTarget("FailClassical", "ToffoliSimulator")
    operation Fail() : Unit is Adj {}

    operation FailClassical() : Unit {}
}

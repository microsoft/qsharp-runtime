namespace AutoEmulationTests {
    @EmulateWith("AutoEmulationTests.SuccessClassical", "ToffoliSimulator")
    operation Success() : Unit is Adj {}

    operation SuccessClassical() : Unit is Adj {}
}

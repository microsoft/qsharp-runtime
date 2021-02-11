namespace AutoEmulationTests {
    @EmulateWith("AutoEmulationTests.SuccessClassical", "ToffoliSimulator")
    operation Success() : Unit {}

    operation SuccessClassical() : Unit {}
}

namespace AutoEmulationTests {
    @EmulateWith("AutoEmulationTests.SuccessClassical", "ToffoliSimulator")
    operation Success() : Unit is Adj+Ctl {}

    operation SuccessClassical() : Unit is Adj+Ctl {}
}

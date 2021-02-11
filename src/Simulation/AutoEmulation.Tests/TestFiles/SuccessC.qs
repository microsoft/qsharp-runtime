namespace AutoEmulationTests {
    @EmulateWith("AutoEmulationTests.SuccessClassical", "ToffoliSimulator")
    operation Success() : Unit is Ctl {}

    operation SuccessClassical() : Unit is Ctl {}
}

namespace AutoEmulationTests {
    @EmulateWith("FailClassical", "ToffoliSimulator")
    operation Fail() : Unit {}

    operation FailClassical() : Unit {}
}

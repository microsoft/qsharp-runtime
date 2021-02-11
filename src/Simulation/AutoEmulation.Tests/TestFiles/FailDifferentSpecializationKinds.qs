namespace AutoEmulationTests {
    @EmulateWith("FailClassical", "ToffoliSimulator")
    operation Fail() : Unit is Adj {}

    operation FailClassical() : Unit {}
}

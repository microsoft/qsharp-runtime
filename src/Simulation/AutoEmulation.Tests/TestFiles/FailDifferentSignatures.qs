namespace AutoEmulationTests {
    @EmulateWith("AutoEmulationTests.FailClassical", "ToffoliSimulator")
    operation Fail(a : Int) : Unit {}

    operation FailClassical(a : Double) : Unit {}
}

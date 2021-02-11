namespace AutoEmulationTests {
    @EmulateWith("Namespace.NotExisting", "ToffoliSimulator")
    operation Fail() : Unit {}
}

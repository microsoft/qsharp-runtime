namespace UtilitiesTests {
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Diagnostics;

    @Test("SparseSimulator")
    operation VerifyResultArrayAsInt() : Unit {
        Fact(ResultArrayAsInt([Zero, Zero, Zero]) == 0, "ResultArrayAsInt of 0 value should work");
        Fact(ResultArrayAsInt([One, Zero, Zero]) == 1, "ResultArrayAsInt of 1 value should work");
        Fact(ResultArrayAsInt([Zero, One, Zero]) == 2, "ResultArrayAsInt of 2 value should work");
        Fact(ResultArrayAsInt([One, One, Zero]) == 3, "ResultArrayAsInt of 3 value should work");
        Fact(ResultArrayAsInt([Zero, Zero, One]) == 4, "ResultArrayAsInt of 4 value should work");
        Fact(ResultArrayAsInt([One, Zero, One]) == 5, "ResultArrayAsInt of 5 value should work");
        Fact(ResultArrayAsInt([Zero, One, One]) == 6, "ResultArrayAsInt of 6 value should work");
        Fact(ResultArrayAsInt([One, One, One]) == 7, "ResultArrayAsInt of 7 value should work");
    }
}
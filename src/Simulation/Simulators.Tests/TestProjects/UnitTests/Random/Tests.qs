namespace Microsoft.Quantum.Tests {
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Random;

    /// # Summary
    /// Checks that DrawRandomDouble obeys ranges.
    @Test("QuantumSimulator")
    @Test("ToffoliSimulator")
    operation CheckDrawRandomDoubleObeysRanges() : Unit {
        for (j in 0..10000) {
            let random = DrawRandomDouble(0.0, 1.0);
            if (random < 0.0 or random > 1.0) {
                fail $"DrawRandomDouble(0.0, 1.0) returned {random}, outside the allowed interval.";
            }
        }
    }

    /// # Summary
    /// Checks that @"microsoft.quantum.canon.randomint" obeys ranges.
    @Test("QuantumSimulator")
    @Test("ToffoliSimulator")
    operation CheckDrawRandomIntObeysRanges () : Unit {
        let randomInt = DrawRandomInt(0, 45);
        if (randomInt > 45 or randomInt < 0) {
            fail $"DrawRandomInt(0, 45) returned {randomInt}, outside the allowed range.";
        }
    }
    

}

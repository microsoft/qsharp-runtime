namespace Microsoft.Quantum.Tests {
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Random;
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Math;

    // Uses Welford's method to compute the mean and variance of an array
    // of samples.
    internal function SampleMeanAndVariance(samples : Double[]) : (Double, Double) {
        mutable meanAcc = 0.0;
        mutable varAcc = 0.0;
        for (idx in 0..Length(samples) - 1) {
            let sample = samples[idx];
            let oldMeanAcc = meanAcc;
            let delta = (sample - meanAcc);
            set meanAcc += delta / IntAsDouble(idx + 1);
            set varAcc += delta * (sample - oldMeanAcc);
        }

        return (meanAcc, varAcc / IntAsDouble(Length(samples) - 1));
    }

    internal operation EstimateMeanAndVariance(dist : ContinuousDistribution, nSamples : Int) : (Double, Double) {
        mutable samples = new Double[nSamples];
        for (idx in 0..nSamples - 1) {
            set samples w/= idx <- dist::Sample();
        }
        return SampleMeanAndVariance(samples);
    }

    internal operation CheckMeanAndVariance(
        name : String,
        distribution : ContinuousDistribution,
        nSamples : Int,
        (expectedMean : Double, expectedVariance : Double),
        tolerance : Double
    ) : Unit {
        let (mean, variance) = EstimateMeanAndVariance(
            distribution,
            nSamples
        );
        Fact(
            expectedMean - tolerance <= mean and
            mean <= expectedMean + tolerance,
            $"Mean of {name} distribution should be {expectedMean}, was {mean}."
        );
        Fact(
            expectedVariance - tolerance <= variance and
            variance <= expectedVariance + tolerance,
            $"Variance of {name} distribution should be {expectedVariance}, was {variance}."
        );
    }

    /// # Summary
    /// Checks that @"microsoft.quantum.random.drawrandomdouble" obeys ranges.
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
    /// Checks that @"microsoft.quantum.random.drawrandomdint" obeys ranges.
    @Test("QuantumSimulator")
    @Test("ToffoliSimulator")
    operation CheckDrawRandomIntObeysRanges () : Unit {
        let randomInt = DrawRandomInt(0, 45);
        if (randomInt > 45 or randomInt < 0) {
            fail $"DrawRandomInt(0, 45) returned {randomInt}, outside the allowed range.";
        }
    }
    
    /// # Summary
    /// Checks that @"microsoft.quantum.random.continuousuniformdistribution" has the
    /// expected moments.
    @Test("QuantumSimulator")
    operation CheckContinuousUniformDistributionHasRightMoments() : Unit {
        CheckMeanAndVariance(
            "uniform",
            ContinuousUniformDistribution(0.0, 1.0),
            1000000,
            (0.5, 1.0 / 12.0),
            0.02
        );
    }

    /// # Summary
    /// Checks that @"microsoft.quantum.random.standardnormaldistribution" has the
    /// expected moments.
    @Test("QuantumSimulator")
    operation CheckStandardNormalDistributionHasRightMoments() : Unit {
        CheckMeanAndVariance(
            "standard normal",
            StandardNormalDistribution(),
            1000000,
            (0.0, 1.0),
            0.02
        );
    }

    /// # Summary
    /// Checks that @"microsoft.quantum.random.normaldistribution" has the
    /// expected moments.
    @Test("QuantumSimulator")
    operation CheckNormalDistributionHasRightMoments() : Unit {
        CheckMeanAndVariance(
            "normal(-2.0, 5.0)",
            NormalDistribution(-2.0, 5.0),
            1000000,
            (-2.0, 5.0),
            0.02
        );
    }

    /// # Summary
    /// Checks that @"microsoft.quantum.random.drawrandombool" has the right
    /// first moment. Note that since DrawRandomBool represents a Bernoulli
    /// trial, it is entirely characterized by its first moment; we don't need
    /// to check variance here.
    @Test("QuantumSimulator")
    operation CheckDrawRandomBoolHasRightExpectation() : Unit {
        // NB: DrawMany isn't available yet, since it's in the
        // Microsoft.Quantum.Standard package, not QSharpCore.
        let prHeads = 0.65;
        let nFlips = 1000000;
        let stdDev = Sqrt(IntAsDouble(nFlips) * prHeads * (1.0 - prHeads));
        let expected = IntAsDouble(nFlips) * prHeads;
        let nAllowedStdDev = 4.0;
        mutable nHeads = 0;
        for (idx in 0..nFlips - 1) {
            if (DrawRandomBool(prHeads)) {
                set nHeads += 1;
            }
        }

        let delta = IntAsDouble(nHeads) - expected;

        Fact(
            -nAllowedStdDev * stdDev <= delta and
            delta <= nAllowedStdDev * stdDev,
            "First moment of Bernoulli distribution was incorrect."
        );
    }
    
}

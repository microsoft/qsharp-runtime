// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

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
        for idx in 0..Length(samples) - 1 {
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
        for idx in 0..nSamples - 1 {
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
    @Test("Microsoft.Quantum.Experimental.OpenSystemsSimulator")
    operation CheckDrawRandomDoubleObeysRanges() : Unit {
        for j in 0..10000 {
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
    @Test("Microsoft.Quantum.Experimental.OpenSystemsSimulator")
    operation CheckDrawRandomIntObeysRanges() : Unit {
        mutable randomInt = DrawRandomInt(0, 45);
        if (randomInt > 45 or randomInt < 0) {
            fail $"DrawRandomInt(0, 45) returned {randomInt}, outside the allowed range.";
        }

        set randomInt = DrawRandomInt(0, 0);
        if (randomInt > 0 or randomInt < 0) {
            fail $"DrawRandomInt(0, 0) returned {randomInt}, outside the allowed range.";
        }

        set randomInt = DrawRandomInt(-3, -3);
        if (randomInt > -3 or randomInt < -3) {
            fail $"DrawRandomInt(-3, -3) returned {randomInt}, outside the allowed range.";
        }

        set randomInt = DrawRandomInt(3, 3);
        if (randomInt > 3 or randomInt < 3) {
            fail $"DrawRandomInt(3, 3) returned {randomInt}, outside the allowed range.";
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

    /// # Summary
    /// Checks that DrawCategorical never draws elements with probability zero.
    @Test("QuantumSimulator")
    operation CheckImpossibleEventsAreNotDrawn() : Unit {
        let distribution = CategoricalDistribution([0.5, 0.0, 0.5]);
        let nTrials = 100000;
        for (idxTrial in 0..nTrials - 1) {
            let variate = distribution::Sample();
            Fact(
                variate != 1,
                "A variate of 1 was drawn from a categorical distribution, despite having a probability of 0."
            );
        }
    }
    
    // We define a couple callables to help us run continuous tests on discrete
    // distributions as well.

    internal operation DrawDiscreteAsContinuous(discrete : DiscreteDistribution, delay : Unit) : Double {
        return IntAsDouble(discrete::Sample());
    }

    internal function DiscreteAsContinuous(discrete : DiscreteDistribution) : ContinuousDistribution {
        return ContinuousDistribution(DrawDiscreteAsContinuous(discrete, _));
    }

    @Test("QuantumSimulator")
    operation CheckCategoricalMomentsAreCorrect() : Unit {
        let categorical = DiscreteAsContinuous(
            CategoricalDistribution([0.2, 0.5, 0.3])
        );
        let expected = 0.0 * 0.2 + 1.0 * 0.5 + 2.0 * 0.3;
        let variance = PowD(0.0 - expected, 2.0) * 0.2 +
                       PowD(1.0 - expected, 2.0) * 0.5 +
                       PowD(2.0 - expected, 2.0) * 0.3;
        
        CheckMeanAndVariance(
            "categorical([0.2, 0.5, 0.3])",
            categorical,
            1000000,
            (expected, variance),
            0.04
        );
    }

    @Test("QuantumSimulator")
    operation CheckRescaledCategoricalMomentsAreCorrect() : Unit {
        let categorical = DiscreteAsContinuous(
            CategoricalDistribution([2.0, 5.0, 3.0])
        );
        let expected = 0.0 * 0.2 + 1.0 * 0.5 + 2.0 * 0.3;
        let variance = PowD(0.0 - expected, 2.0) * 0.2 +
                       PowD(1.0 - expected, 2.0) * 0.5 +
                       PowD(2.0 - expected, 2.0) * 0.3;
        
        CheckMeanAndVariance(
            "categorical([0.2, 0.5, 0.3])",
            categorical,
            1000000,
            (expected, variance),
            0.04
        );
    }
    
    @Test("QuantumSimulator")
    operation CheckCategoricalHistogramIsCorrect() : Unit {
        let categorical = CategoricalDistribution([0.2, 0.5, 0.3]);
        mutable counts = new Int[3];
        let nSamples = 1000000;

        for (idx in 0..nSamples - 1) {
            let sample = categorical::Sample();
            set counts w/= sample <- counts[sample] + 1;
        }

        Fact(190000 <= counts[0] and counts[0] <= 210000, $"counts[0] was {counts[0]}, expected about 200000.");
        Fact(490000 <= counts[1] and counts[1] <= 510000, $"counts[1] was {counts[1]}, expected about 500000.");
        Fact(290000 <= counts[2] and counts[2] <= 310000, $"counts[2] was {counts[2]}, expected about 300000.");
    }

    @Test("QuantumSimulator")
    operation CheckDiscreteUniformMomentsAreCorrect() : Unit {
        let (min, max) = (-3, 7);
        let expected = 0.5  * (IntAsDouble(min + max));
        let variance = (1.0 / 12.0) * (
            PowD(IntAsDouble(max - min + 1), 2.0) - 1.0
        );
        CheckMeanAndVariance(
            $"discrete uniform ({min}, {max})",
            DiscreteAsContinuous(
                DiscreteUniformDistribution(min, max)
            ),
            1000000,
            (expected, variance),
            0.1
        );
    }

}

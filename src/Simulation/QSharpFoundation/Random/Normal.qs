// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Random {
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Math;

    internal operation DrawStandardNormalVariate() : Double {
        let (u1, u2) = (DrawRandomDouble(0.0, 1.0), DrawRandomDouble(0.0, 1.0));
        return Sqrt(-2.0 * Log(u1)) * Cos(2.0 * PI() * u2);
    }

    /// # Summary
    /// Returns a normal distribution with mean 0 and variance 1.
    ///
    /// # Example
    /// The following draws 10 samples from the standard normal distribution:
    /// ```qsharp
    /// let samples = DrawMany((StandardNormalDistribution())::Sample, 10, ());
    /// ```
    ///
    /// # See Also
    /// - Microsoft.Quantum.Random.NormalDistribution
    function StandardNormalDistribution() : ContinuousDistribution {
        return ContinuousDistribution(DrawStandardNormalVariate);
    }

    internal function StandardTransformation(mean : Double, variance : Double, variate : Double) : Double {
        return mean + Sqrt(variance) * variate;
    }

    /// # Summary
    /// Returns a normal distribution with a given mean and variance.
    ///
    /// # Example
    /// The following draws 10 samples from the normal distribution with mean
    /// 2 and standard deviation 0.1:
    /// ```qsharp
    /// let samples = DrawMany(
    ///     (NormalDistribution(2.0, PowD(0.1, 2.0)))::Sample,
    ///     10, ()
    /// );
    /// ```
    ///
    /// # See Also
    /// - Microsoft.Quantum.Random.StandardNormalDistribution
    function NormalDistribution(mean : Double, variance : Double) : ContinuousDistribution {
        return TransformedContinuousDistribution(
            StandardTransformation(mean, variance, _),
            StandardNormalDistribution()
        );
    }

}

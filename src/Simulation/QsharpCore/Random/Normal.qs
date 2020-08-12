// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Random {
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Math;

    internal operation DrawStandardNormalVariate() : Double {
        let (u1, u2) = (DrawRandomDouble(0.0, 1.0), DrawRandomDouble(0.0, 1.0));
        return Sqrt(-2.0 * Log(u1)) * Cos(2.0 * PI() * u2);
    }

    function StandardNormalDistribution() : ContinuousDistribution {
        return ContinuousDistribution(DrawStandardNormalVariate);
    }

    internal function StandardTransformation(mean : Double, variance : Double, variate : Double) : Double {
        return mean + Sqrt(variance) * variate;
    }

    function NormalDistribution(mean : Double, variance : Double) : ContinuousDistribution {
        return TransformedContinuousDistribution(
            StandardTransformation(mean, variance, _),
            StandardNormalDistribution()
        );
    }

}

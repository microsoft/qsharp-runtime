// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Random {
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Math;

    newtype ContinuousDistribution = (
        Sample : (Unit => Double)
    );

    newtype ComplexDistribution = (
        Sample : (Unit => Complex)
    );

    newtype DiscreteDistribution = (
        Sample : (Unit => Int)
    );

    newtype BigDiscreteDistribution = (
        Sample : (Unit => BigInt)
    );

    function CategoricalDistribution(probs : Double[]) : DiscreteDistribution {
        return DiscreteDistribution(Delay(DrawCategorial, probs, _));
    }

    internal operation SampleTransformedContinuousDistribution(
        transform : (Double -> Double),
        distribution : ContinuousDistribution
    ) : Double {
        return transform(distribution::Sample());
    }

    function TransformedContinuousDistribution(
        transform : (Double -> Double),
        distribution : ContinuousDistribution
    ) : ContinuousDistribution {
        return ContinuousDistribution(Delay(
            SampleTransformedContinuousDistribution,
            (transform, distribution), 
            _
        ));
    }

}

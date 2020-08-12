// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Random {
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Math;


    function ContinuousUniformDistribution(
        min : Double, max : Double
    ) : ContinuousDistribution {
        return ContinuousDistribution(Delay(DrawRandomDouble, (min, max), _));
    }

    function DiscreteUniformDistribution(min : Int, max : Int) : DiscreteDistribution {
        return DiscreteDistribution(Delay(DrawRandomInt, (min, max), _));
    }

}

// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Random {
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Math;

    /// # Summary
    /// Represents a univariate probability distribution over real numbers.
    ///
    /// # See Also
    /// - Microsoft.Quantum.Random.ComplexDistribution
    /// - Microsoft.Quantum.Random.DiscreteDistribution
    /// - Microsoft.Quantum.Random.BigDiscreteDistribution
    newtype ContinuousDistribution = (
        Sample : (Unit => Double)
    );

    
    /// # Summary
    /// Represents a univariate probability distribution over complex numbers.
    ///
    /// # See Also
    /// - Microsoft.Quantum.Random.ContinuousDistribution
    /// - Microsoft.Quantum.Random.DiscreteDistribution
    /// - Microsoft.Quantum.Random.BigDiscreteDistribution
    newtype ComplexDistribution = (
        Sample : (Unit => Complex)
    );

    /// # Summary
    /// Represents a univariate probability distribution over integers.
    ///
    /// # See Also
    /// - Microsoft.Quantum.Random.ContinuousDistribution
    /// - Microsoft.Quantum.Random.ComplexDistribution
    /// - Microsoft.Quantum.Random.BigDiscreteDistribution
    newtype DiscreteDistribution = (
        Sample : (Unit => Int)
    );

    /// # Summary
    /// Represents a univariate probability distribution over integers of
    /// arbitrary size.
    ///
    /// # See Also
    /// - Microsoft.Quantum.Random.ContinuousDistribution
    /// - Microsoft.Quantum.Random.ComplexDistribution
    /// - Microsoft.Quantum.Random.DiscreteDistribution
    newtype BigDiscreteDistribution = (
        Sample : (Unit => BigInt)
    );

    /// # Summary
    /// Returns a discrete categorical distribution, in which the probability
    /// for each of a finite list of given outcomes is explicitly specified.
    ///
    /// # Input
    /// ## probs
    /// The probabilities for each outcome from the categorical distribution.
    /// These probabilities may not be normalized, but must all be non-negative.
    ///
    /// # Output
    /// The index `i` with probability `probs[i] / sum`, where `sum` is the sum
    /// of `probs` given by `Fold(PlusD, 0.0, probs)`.
    ///
    /// # Example
    /// The following Q# code will display 0 with probability 30% and 1 with
    /// probability 70%:
    /// ```qsharp
    /// let dist = CategoricalDistribution([0.3, 0.7]);
    /// Message($"Got sample: {dist::Sample()}");
    /// ```
    function CategoricalDistribution(probs : Double[]) : DiscreteDistribution {
        return DiscreteDistribution(Delay(DrawCategorical, probs, _));
    }

    /// # Summary
    /// Internal-only operation for sampling from transformed distributions.
    /// Should only be used via partial application.
    internal operation SampleTransformedContinuousDistribution(
        transform : (Double -> Double),
        distribution : ContinuousDistribution
    ) : Double {
        return transform(distribution::Sample());
    }

    /// # Summary
    /// Given a continuous distribution, returns a new distribution that
    /// transforms the original by a given function.
    ///
    /// # Input
    /// ## transform
    /// A function that transforms variates of the original distribution to the
    /// transformed distribution.
    /// ## distribution
    /// The original distribution to be transformed.
    ///
    /// # Output
    /// A new distribution related to `distribution` by the transformation given
    /// by `transform`.
    ///
    /// # Example
    /// The following two distributions are identical:
    /// ```qsharp
    /// let dist1 = ContinuousUniformDistribution(1.0, 2.0);
    /// let dist2 = TransformedContinuousDistribution(
    ///     PlusD(1.0, _),
    ///     ContinuousUniformDistribution(0.0, 1.0)
    /// );
    /// ```
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

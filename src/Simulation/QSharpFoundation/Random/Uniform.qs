// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Random {
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Diagnostics;

    /// # Summary
    /// Returns a uniform distribution over a given inclusive interval.
    ///
    /// # Input
    /// ## min
    /// The smallest real number to be drawn.
    /// ## max
    /// The largest real number to be drawn.
    ///
    /// # Output
    /// A distribution whose random variates are real numbers in the inclusive
    /// interval from `min` to `max` with uniform probability.
    ///
    /// # Remarks
    /// Fails if `max < min`.
    ///
    /// # Example
    /// The following Q# snippet randomly draws an angle between $0$ and $2 \pi$:
    /// ```qsharp
    /// let angleDistribution = ContinuousUniformDistribution(0.0, 2.0 * PI());
    /// let angle = angleDistribution::Sample();
    /// ```
    ///
    /// # See Also
    /// - Microsoft.Quantum.DrawRandomDouble
    function ContinuousUniformDistribution(
        min : Double, max : Double
    ) : ContinuousDistribution {
        Fact(max >= min, $"Max must be greater than or equal to min, but {max} < {min}.");
        return ContinuousDistribution(Delay(DrawRandomDouble, (min, max), _));
    }

    /// # Summary
    /// Returns a uniform distribution over a given inclusive range.
    ///
    /// # Input
    /// ## min
    /// The smallest integer to be drawn.
    /// ## max
    /// The largest integer to be drawn.
    ///
    /// # Output
    /// A distribution whose random variates are integers in the inclusive
    /// range from `min` to `max` with uniform probability.
    ///
    /// # Remarks
    /// Fails if `max < min`.
    ///
    /// # Example
    /// The following Q# snippet randomly rolls a six-sided die:
    /// ```qsharp
    /// let dieDistribution = DiscreteUniformDistribution(1, 6);
    /// let dieRoll = dieDistribution::Sample();
    /// ```
    ///
    /// # See Also
    /// - Microsoft.Quantum.DrawRandomDouble
    function DiscreteUniformDistribution(min : Int, max : Int) : DiscreteDistribution {
        Fact(max >= min, $"Max must be greater than or equal to min, but {max} < {min}.");
        return DiscreteDistribution(Delay(DrawRandomInt, (min, max), _));
    }

}

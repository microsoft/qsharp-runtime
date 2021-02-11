// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Random {
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Diagnostics;

    /// # Summary
    /// Draws a random sample from a categorical distribution specified by a
    /// list of probablities.
    ///
    /// # Description
    /// The probability of selecting a specific index is proportional to the value
    /// of the array element at that index.
    /// Array elements that are equal to zero are ignored and their indices are never
    /// returned. If any array element is less than zero,
    /// or if no array element is greater than zero, then the operation fails.
    ///
    /// # Input
    /// ## probs
    /// An array of floating-point numbers proportional to the probability of
    /// selecting each index.
    ///
    /// # Output
    /// An integer $i$ with probability $\Pr(i) = p_i / \sum_i p_i$, where $p_i$
    /// is the $i$th element of `probs`.
    ///
    /// # See Also
    /// - Microsoft.Quantum.Random.CategoricalDistribution
    operation DrawCategorical(probs : Double[]) : Int {
        // There are nicer ways of doing this, but they require the full
        // standard library to be available.
        mutable sum = 0.0;
        for prob in probs {
            Fact(prob >= 0.0, "Probabilities must be positive.");
            set sum += prob;
        }

        let variate = DrawRandomDouble(0.0, sum);
        mutable acc = 0.0;
        for idx in 0..Length(probs) - 1 {
            set acc += probs[idx];
            if (variate <= acc) {
                return idx;
            }
        }

        return Length(probs) - 1;
    }

    /// # Summary
    /// Draws a random Pauli value.
    ///
    /// # Output
    /// Either `PauliI`, `PauliX`, `PauliY`, or `PauliZ` with equal
    /// probability.
    operation DrawRandomPauli() : Pauli {
        return [PauliI, PauliX, PauliY, PauliZ][DrawRandomInt(0, 3)];
    }

    /// # Summary
    /// Given an array of data and an a distribution over its indices,
    /// attempts to choose an element at random.
    ///
    /// # Input
    /// ## data
    /// The array from which an element should be chosen.
    /// ## indexDistribution
    /// A distribution over the indices of `data`.
    ///
    /// # Ouput
    /// A tuple `(succeeded, element)` where `succeeded` is `true` if and only
    /// if the sample chosen from `indexDistribution` was a valid index into
    /// `data`, and where `element` is an element of `data` chosen at random.
    ///
    /// # Example
    /// The following Q# snippet chooses an element at random from an array:
    /// ```qsharp
    /// let (succeeded, element) = MaybeChooseElement(
    ///     data,
    ///     DiscreteUniformDistribution(0, Length(data) - 1)
    /// );
    /// Fact(succeeded, "Index chosen by MaybeChooseElement was not valid.");
    /// ```
    operation MaybeChooseElement<'T>(data : 'T[], indexDistribution : DiscreteDistribution) : (Bool, 'T) {
        let index = indexDistribution::Sample();
        if (index >= 0 and index < Length(data)) {
            return (true, data[index]);
        } else {
            return (false, Default<'T>());
        }
    }

    /// # Summary
    /// Given a success probability, returns a single Bernoulli trial that 
    /// is true with the given probability.
    ///
    /// # Input
    /// ## successProbability
    /// The probability with which `true` should be returned.
    ///
    /// # Output
    /// `true` with probability `successProbability` and `false` with
    /// probability `1.0 - successProbability`.
    ///
    /// # Example
    /// The following Q# snippet samples flips from a biased coin:
    /// ```qsharp
    /// let flips = DrawMany(DrawRandomBool, 10, 0.6);
    /// ```
    operation DrawRandomBool(successProbability : Double) : Bool {
        return DrawRandomDouble(0.0, 1.0) <= successProbability;
    }
}

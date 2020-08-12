// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Random {
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Diagnostics;

    /// # Summary
    /// The random operation takes an array of doubles as input, and returns
    /// a randomly-selected index into the array as an `Int`.
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
    operation DrawCategorial(probs : Double[]) : Int {
        // There are nicer ways of doing this, but they require the full
        // standard library to be available.
        mutable sum = 0.0;
        for (prob in probs) {
            Fact(prob >= 0.0, "Probabilities must be positive.");
            set sum += prob;
        }

        let variate = DrawRandomDouble(0.0, sum);
        mutable acc = 0.0;
        for (idx in 0..Length(probs) - 1) {
            set acc += probs[idx];
            if (variate <= acc) {
                return idx;
            }
        }

        return Length(probs) - 1;
    }

    operation DrawRandomPauli() : Pauli {
        return [PauliI, PauliX, PauliY, PauliZ][DrawRandomInt(0, 3)];
    }

    operation MaybeChooseElement<'T>(data : 'T[], indexDistribution : DiscreteDistribution) : (Bool, 'T) {
        let index = indexDistribution::Sample();
        if (index >= 0 and index < Length(data)) {
            return (true, data[index]);
        } else {
            return (false, Default<'T>());
        }
    }

    operation DrawBinomialSample(successProbability : Double) : Bool {
        return DrawRandomDouble(0.0, 1.0) <= successProbability;
    }
}

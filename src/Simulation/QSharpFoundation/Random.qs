// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Intrinsic {
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
    @Deprecated("Microsoft.Quantum.Random.DrawCategorical")
    operation Random (probs : Double[]) : Int {
        return Microsoft.Quantum.Random.DrawCategorical(probs);
    }
}

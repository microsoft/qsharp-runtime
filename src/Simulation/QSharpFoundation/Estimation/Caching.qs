// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

// Functionality needed to instruct the resource estimator to cache costs of a code fragment
// and reuse these costs without executing the code fragment repeatedly. This functionality
// is only available when using resource estimator execution target. `BeginCostCaching`
// and `EndCostCaching` are not defined for other execution targets.

namespace Microsoft.Quantum.ResourceEstimation {

    /// # Summary
    /// Used to specify that there's only one execution variant in `BeginCostCaching`
    /// function
    function SingleVariant() : Int {
        return 0;
    }

    /// # Summary
    /// Instructs the resource estimator of the start of the code fragment
    /// for which costs caching can be done.
    ///
    /// # Input
    /// ## name
    /// The name of the code fragment. Used to distinguish it from other code fragments.
    /// Typically this is the name of the operation for which costs can be cached.
    /// ## variant
    /// Specific variant of the execution. Cached costs can only be reused if the
    /// variant for which they were collected and the current variant is the same.
    ///
    /// # Output
    /// `false` indicates if cached costs have been incorporated into the overall costs
    /// and the code fragment should be skipped.
    /// `true` indicated that the cached costs are not yet avialable and the code fragment
    /// needs to be executed in order to collect and cache costs.
    function BeginCostCaching(name: String, variant: Int): Bool {
        body intrinsic;
    }

    /// # Summary
    /// Instructs the resource estimator that the code fragment is over.
    function EndCostCaching(): Unit {
        body intrinsic;
    }

}

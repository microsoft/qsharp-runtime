// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

// Functionality needed to instruct the resource estimator to cache estimates of a code fragment
// and reuse these estimates without executing the code fragment repeatedly. This functionality
// is only available when using resource estimator execution target. `BeginCostCaching`
// and `EndCostCaching` are not defined for other execution targets.

namespace Microsoft.Quantum.ResourceEstimation {

    /// # Summary
    /// Used to specify that there's only one execution variant in `BeginEstimateCaching`
    /// function
    function SingleVariant() : Int {
        return 0;
    }

    /// # Summary
    /// Informs the resource estimator of the start of the code fragment
    /// for which estimates caching can be done. This function
    /// is only available when using resource estimator execution target.
    ///
    /// # Input
    /// ## name
    /// The name of the code fragment. Used to distinguish it from other code fragments.
    /// Typically this is the name of the operation for which estimates can be cached.
    /// ## variant
    /// Specific variant of the execution. Cached estimates can only be reused if the
    /// variant for which they were collected and the current variant is the same.
    ///
    /// # Output
    /// `true` indicated that the cached estimates are not yet avialable and the code fragment
    /// needs to be executed in order to collect and cache estimates.
    /// `false` indicates if cached estimates have been incorporated into the overall costs
    /// and the code fragment should be skipped.
    function BeginEstimateCaching(name: String, variant: Int): Bool {
        body intrinsic;
    }

    /// # Summary
    /// Instructs the resource estimator to stop estimates caching
    /// because the code fragment in consideration is over. This function
    /// is only available when using resource estimator execution target.
    function EndEstimateCaching(): Unit {
        body intrinsic;
    }

}

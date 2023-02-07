// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

// Functionality needed to instruct the resources estimator to cache costs of a code fragment
// and reuse these costs without executing the code fragment repeatedly. These functions are
// only applicable to the resources estimator and have no effect in other targets (for example,
// the `BeginCostCaching` always returns `true` for other targets).

namespace Microsoft.Quantum.Estimation {

    /// # Summary
    /// Instructs the resources estimator of the start of the code fragment
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
    /// Instructs the resources estimator that the code fragment is over.
    function EndCostCaching(): Unit {
        body intrinsic;
    }

}

// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Targeting {
    /// # Summary
    /// Enables to substitute an operation with an alternative operation for a given target
    ///
    /// # Named Items
    /// ## AlternativeOperation
    /// Fully qualified name of alternative operation to substitute operation with.
    ///
    /// ## TargetName
    /// One of `QuantumSimulator`, `ToffoliSimulator`, or `ResourcesEstimator`, or a fully qualified name
    /// of a custom target.
    @Attribute()
    newtype SubstitutableOnTarget = (AlternativeOperation : String, TargetName : String);
}

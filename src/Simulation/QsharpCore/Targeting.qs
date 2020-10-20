// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

/// # Summary
/// This namespace includes Q# core functions and operations.
namespace Microsoft.Quantum.Targeting {
    /// # Summary
    /// Compiler-recognized attribute used to mark a callable with the runtime capabilities it
    /// requires.
    ///
    /// # Named Items
    /// ## Level
    /// The name of the runtime capability level required by the callable.
    ///
    /// ## Reason
    /// A description of why the callable requires this runtime capability.
    /// 
    /// # Remarks
    /// The valid capability level names, in order of increasing capabilities (or decreasing
    /// restrictions), are:
    ///
    /// ## `"BasicQuantumFunctionality"`
    /// Measurement results cannot be compared for equality.
    ///
    /// ## `"BasicMeasurementFeedback"`
    /// Measurement results can be compared for equality only in if-statement conditional
    /// expressions in operations. The block of an if-statement that depends on a result cannot
    /// contain set statements for mutable variables declared outside the block, or return
    /// statements.
    ///
    /// ## FullComputation
    /// No runtime restrictions. Any Q# program can be executed.
    @Attribute()
    newtype RequiresCapability = (Level : String, Reason : String);
}

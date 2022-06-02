// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

/// # Summary
/// This namespace provides functionality for targeting specific quantum processors.
namespace Microsoft.Quantum.Targeting {
    /// # Summary
    /// Compiler-recognized attribute used to mark a callable with its required target capabilities.
    ///
    /// # Remarks
    /// This attribute is used internally by the compiler and standard library. Its API is unstable
    /// and should not be used.
    @Attribute()
    newtype RequiresCapability = (ResultOpacity : String, Classical : String, Reason : String);

    /// # Summary
    /// Compiler-recognized attribute for usage within target-specific packages 
    /// to specify the name of the instruction on the target machine.
    @Attribute()
    newtype TargetInstruction = String;
}

// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

/// # Summary
/// This namespace provides functionality for targeting specific quantum processors.
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
    /// This attribute is automatically added to callables by the compiler, unless an instance of
    /// this attribute already exists on the callable. It should not be used except in rare cases
    /// where the compiler does not infer the required capability correctly.
    ///
    /// Below is the list of capability level names, in order of increasing capabilities or
    /// decreasing restrictions:
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
    /// ## `"FullComputation"`
    /// No runtime restrictions. Any Q# program can be executed.
    @Attribute()
    newtype RequiresCapability = (Level : String, Reason : String);


    /// # Summary
    /// Compiler-recognized attribute for usage within target-specific packages 
    /// to specify the name of the instruction on the target machine.
    @Attribute()
    newtype TargetInstruction = String;
}

// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

/// # Summary
/// This namespace includes Q# core functions and operations.
///
/// # Remarks
/// This namespace is opened automatically by the Q# compiler, so all
/// elements of this namespace are always available.
namespace Microsoft.Quantum.Core {
    
    /// # Summary
    /// Compiler-recognized attribute used to mark user-defined types as attributes. 
    @Attribute()
    newtype Attribute = Unit;

    /// # Summary
    /// Compiler-recognized attribute used to mark the entry point of an executable.
    @Attribute()
    newtype EntryPoint = Unit;

    /// # Summary
    /// Compiler-recognized attribute used during QIR emission to determine 
    /// when callables should be inlined, if possible.
    @Attribute()
    newtype Inline = Unit;

    /// # Summary
    /// Compiler-recognized attribute used to mark a type or callable as deprecated.
    /// 
    /// # Named Items
    /// ## NewName
    /// The full name of the type or callable to use instead. 
    /// Is set to the empty String if a type or callable has been deprecated without substitution. 
    ///
    @Attribute()
    newtype Deprecated = (NewName : String);

    /// # Summary
    /// Returns a default instance of the specified type. 
    ///
    /// # Output
    /// Default value.
    ///
    /// # Type Parameters
    /// ## 'T
    /// The type of the default value to return. 
    ///
    function Default<'T> () : 'T {
        return (new 'T[1])[0];
    }

    /// # Summary
    /// Returns the number of elements in an array.
    ///
    /// # Input
    /// ## a
    /// Input array.
    ///
    /// # Output
    /// The total count of elements in an array.
    ///
    function Length<'T> (a : 'T[]) : Int {
        body intrinsic;
    }
    
    /// # Summary
    /// Returns the defined start value of the given range.
    ///
    /// # Input
    /// ## range
    /// Input range.
    ///
    /// # Output
    /// The defined start value of the given range.
    ///
    /// # Remarks
    /// A range expression's first element is `start`,
    /// its second element is `start+step`, third element is `start+step+step`, etc.,
    /// until `end` is passed.
    /// 
    /// Note that the defined start value of a range is the same as the first element of the sequence,
    /// unless the range specifies an empty sequence (for example, 2 .. 1).
    function RangeStart (range : Range) : Int {
        body intrinsic;
    }
    
    
    /// # Summary
    /// Returns the defined end value of the given range,
    /// which is not necessarily the last element in the sequence.
    ///
    /// # Input
    /// ## range
    /// Input range.
    ///
    /// # Output
    /// The defined end value of the given range.
    ///
    /// # Remarks
    /// A range expression's first element is `start`,
    /// its second element is `start+step`, third element is `start+step+step`, etc.,
    /// until `end` is passed.
    /// 
    /// Note that the defined end value of a range can differ from the last element in the sequence specified by the range;
    /// for example, in a range 0 .. 2 .. 5 the last element is 4 but the end value is 5.
    function RangeEnd (range : Range) : Int {
        body intrinsic;
    }
    
    
    /// # Summary
    /// Returns the integer that specifies how the next value of a range is calculated.
    ///
    /// # Input
    /// ## range
    /// Input range.
    ///
    /// # Output
    /// The defined step value of the given range.
    ///
    /// # Remarks
    /// A range expression's first element is `start`,
    /// its second element is `start+step`, third element is `start+step+step`, etc.,
    /// until `end` is passed.
    function RangeStep (range : Range) : Int {
        body intrinsic;
    }

    /// # Summary
    /// Returns a new range which is the reverse of the input range.
    ///
    /// # Input
    /// ## range
    /// Input range.
    ///
    /// # Output
    /// A new range that is the reverse of the given range.
    ///
    /// # Remarks
    /// Note that the reverse of a range is not simply `end`..`-step`..`start`, because
    /// the actual last element of a range may not be the same as `end`.
    function RangeReverse(range : Range) : Range {
        body intrinsic;
    }

}

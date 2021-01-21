// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Arrays {

    /// # Summary
    /// Returns the empty array of a given type.
    ///
    /// # Type Parameters
    /// ## 'TElement
    /// The type of elements of the array.
    ///
    /// # Output
    /// The empty array.
    ///
    /// # Example
    /// ```Q#
    /// let empty = EmptyArray<Int>();
    /// ```
    function EmptyArray<'TElement>() : 'TElement[] {
        body intrinsic;
    }

}

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
    /// ```qsharp
    /// let empty = EmptyArray<Int>();
    /// ```
    function EmptyArray<'TElement>() : 'TElement[] {
        return new 'TElement[0];
    }

}

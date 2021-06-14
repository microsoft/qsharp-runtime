// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Intrinsic {
    /// # Summary
    /// Logs a message.
    ///
    /// # Input
    /// ## msg
    /// The message to be reported.
    ///
    /// # Remarks
    /// The specific behavior of this function is simulator-dependent,
    /// but in most cases the given message will be written to the console.
    ///
    /// # Example
    /// The following causes `"Hello, world!"` to be reported (typically to
    /// the console):
    /// ```qsharp
    /// let name = "world";
    /// Message($"Hello, {name}!");
    /// ```
    function Message (msg : String) : Unit {
        body intrinsic;
    }
}
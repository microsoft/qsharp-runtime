// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Diagnostics {

    /// # Summary
    /// Declares that a classical condition is true.
    ///
    /// # Input
    /// ## actual
    /// The condition to be declared.
    /// ## message
    /// Failure message string to be printed in the case that the classical
    /// condition is false.
    ///
    /// # See Also
    /// - Microsoft.Quantum.Diagnostics.Contradiction
    ///
    /// # Example
    /// The following Q# snippet will fail:
    /// ```Q#
    /// Fact(false, "Expected true.");
    /// ```
    function Fact(actual : Bool, message : String) : Unit {
        if (not actual) { fail message; }
    }

    /// # Summary
    /// Declares that a classical condition is false.
    ///
    /// # Input
    /// ## actual
    /// The condition to be declared.
    /// ## message
    /// Failure message string to be printed in the case that the classical
    /// condition is true.
    ///
    /// # See Also
    /// - Microsoft.Quantum.Diagnostics.Fact
    ///
    /// # Example
    /// The following Q# code will print "Hello, world":
    /// ```Q#
    /// Contradiction(2 == 3, "2 is not equal to 3.");
    /// Message("Hello, world.");
    /// ```
    function Contradiction(actual : Bool, message : String) : Unit {
        if (actual) { fail message; }
    }

}

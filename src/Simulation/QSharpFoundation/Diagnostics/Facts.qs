// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Diagnostics {
    open Microsoft.Quantum.Math;

    /// # Summary
    /// Checks whether a classical condition is true, and throws an exception if it is not.
    ///
    /// # Input
    /// ## actual
    /// The condition to be checked.
    /// ## message
    /// Failure message string to be used as an error message if the classical
    /// condition is false.
    ///
    /// # See Also
    /// - Microsoft.Quantum.Diagnostics.Contradiction
    ///
    /// # Example
    /// The following Q# snippet will throw an exception:
    /// ```qsharp
    /// Fact(false, "Expected true.");
    /// ```
    function Fact(actual : Bool, message : String) : Unit {
        if (not actual) { fail message; }
    }

    /// # Summary
    /// Checks whether a classical condition is false, and throws an exception if it is not.
    ///
    /// # Input
    /// ## actual
    /// The condition to be checked.
    /// ## message
    /// Failure message string to be used as an error message if the classical
    /// condition is true.
    ///
    /// # See Also
    /// - Microsoft.Quantum.Diagnostics.Fact
    ///
    /// # Example
    /// The following Q# code will print "Hello, world":
    /// ```qsharp
    /// Contradiction(2 == 3, "2 is not equal to 3.");
    /// Message("Hello, world.");
    /// ```
    function Contradiction(actual : Bool, message : String) : Unit {
        if (actual) { fail message; }
    }

    /// # Summary
    /// Checks whether a given floating-point value represents a finite
    /// number, and throws an exception if this is not the case.
    ///
    /// # Input
    /// ## d
    /// The floating-point value that is to be checked.
    /// ## message
    /// Failure message to be used as an error message if `d` is either
    /// not finite, or not a number.
    ///
    /// # Example
    /// The following Q# code will throw an exception:
    /// ```qsharp
    /// FiniteFact(NaN(), "NaN is not a finite number.");
    /// ```
    ///
    /// # See Also
    /// - Microsoft.Quantum.Diagnostics.Fact
    function FiniteFact(d : Double, message : String) : Unit {
        Fact(IsFinite(d), message);
    }

}

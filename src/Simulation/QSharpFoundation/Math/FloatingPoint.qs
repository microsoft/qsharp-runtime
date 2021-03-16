// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Math {

    /// # Summary
    /// Returns a value that is not a number (i.e. NaN).
    ///
    /// # Ouputs
    /// A double-precision floating point value that is not a number.
    ///
    /// # Remarks
    /// The value output by this function follows IEEE 754 rules for how `NaN`
    /// works when used with other double-precision floating point values.
    /// For example, for any value `x` of type `Double`, `NaN() == x` is
    /// `false`; this holds even if `x` is also `NaN()`.
    ///
    /// # See Also
    /// - Microsoft.Quantum.Math.IsNaN
    /// - Microsoft.Quantum.Math.IsInfinite
    /// - Microsoft.Quantum.Math.IsFinite
    function NaN() : Double {
        return 0.0 / 0.0;
    }

    /// # Summary
    /// Returns whether a given floating-point value is not a number (i.e.
    /// is NaN).
    ///
    /// # Input
    /// ## d
    /// A floating-point value to be checked.
    ///
    /// # Output
    /// `true` if and only if `d` is not a number.
    ///
    /// # Remarks
    /// Since `NaN()` is the only floating-point value that does not equal
    /// itself, this function should be used instead of checking conditions such
    /// as `d == NaN()`.
    ///
    /// # See Also
    /// - Microsoft.Quantum.Math.NaN
    /// - Microsoft.Quantum.Math.IsInfinite
    /// - Microsoft.Quantum.Math.IsFinite
    function IsNaN(d : Double) : Bool {
        return d != d;
    }

    /// # Summary
    /// Returns whether a given floating-point value is either positive or
    /// negative infinity.
    ///
    /// # Input
    /// ## d
    /// The floating-point value to be checked.
    ///
    /// # Ouput
    /// `true` if and only if `d` is either positive or negative infinity.
    ///
    /// # Remarks
    /// `NaN()` is not a number, and is thus neither a finite number nor
    /// is it infinite. As such, both `IsInfinite(NaN())` and `IsFinite(NaN())`
    /// return `false`. To check a value against `NaN()`, use `IsNaN(d)`.
    ///
    /// 
    /// Note that even though this function returns `true` for both
    /// positive and negative infinities, these values can still be
    /// discriminated by checking `d > 0.0` and `d < 0.0`.
    ///
    /// # Example
    /// ```qsharp
    /// Message($"{IsInfinite(42.0)}"); // false
    /// Message($"{IsInfinite(NaN())}"); // false
    /// Message($"{IsInfinite(-1.0 / 0.0}"); // true
    ///
    /// # See Also
    /// - Microsoft.Quantum.Math.NaN
    /// - Microsoft.Quantum.Math.IsNaN
    /// - Microsoft.Quantum.Math.IsFinite
    /// ```
    function IsInfinite(d : Double) : Bool {
        return d == 1.0 / 0.0 or d == -1.0 / 0.0;
    }

    /// # Summary
    /// Returns whether a given floating-point value is a finite number.
    ///
    /// # Input
    /// ## d
    /// The floating-point value to be checked.
    ///
    /// # Ouput
    /// `true` if and only if `d` is a finite number (i.e.: is neither infinite
    /// nor NaN).
    ///
    /// # Remarks
    /// `NaN()` is not a number, and is thus neither a finite number nor
    /// is it infinite. As such, both `IsInfinite(NaN())` and `IsFinite(NaN())`
    /// return `false`. To check a value against `NaN()`, use `IsNaN(d)`.
    ///
    /// # Example
    /// ```qsharp
    /// Message($"{IsFinite(42.0)}"); // true
    /// Message($"{IsFinite(NaN())}"); // false
    /// Message($"{IsFinite(-1.0 / 0.0)}"); // false
    ///
    /// # See Also
    /// - Microsoft.Quantum.Math.NaN
    /// - Microsoft.Quantum.Math.IsNaN
    /// - Microsoft.Quantum.Math.IsInfinite
    /// ```
    function IsFinite(d : Double) : Bool {
        return not IsInfinite(d) and not IsNaN(d);
    }
}

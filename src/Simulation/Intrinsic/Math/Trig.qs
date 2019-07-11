// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

// these are all the static methods and const fields  form System.Math class of .NET CLR
// that are not exposed as language operators and are relevant within type System.
// If there are two versions of the function for Int and Double types, the corresponding
// functions have suffix I or D. ExpD also has a suffix to avoid name clash with Primitives.Exp.

namespace Microsoft.Quantum.Math {

    /// # Summary
    /// Returns the angle whose cosine is the specified number.
    ///
    /// # Remarks
    /// See [System.Math.Acos](https://docs.microsoft.com/dotnet/api/system.math.acos) for more details.
    function ArcCos (x : Double) : Double {
        body intrinsic;
    }

    /// # Summary
    /// Returns the angle whose sine is the specified number.
    ///
    /// # Remarks
    /// See [System.Math.Asin](https://docs.microsoft.com/dotnet/api/system.math.asin) for more details.
    function ArcSin (y : Double) : Double {
        body intrinsic;
    }

    /// # Summary
    /// Returns the angle whose tangent is the specified number.
    ///
    /// # Remarks
    /// See [System.Math.Atan](https://docs.microsoft.com/dotnet/api/system.math.atan) for more details.
    function ArcTan (d : Double) : Double {
        body intrinsic;
    }

    /// # Summary
    /// Returns the angle whose tangent is the quotient of two specified numbers.
    ///
    /// # Remarks
    /// See [System.Math.Atan2](https://docs.microsoft.com/dotnet/api/system.math.atan2) for more details.
    function ArcTan2 (y : Double, x : Double) : Double {
        body intrinsic;
    }

    /// # Summary
    /// Returns the cosine of the specified angle.
    ///
    /// # Remarks
    /// See [System.Math.Cos](https://docs.microsoft.com/dotnet/api/system.math.cos) for more details.
    function Cos (theta : Double) : Double {
        body intrinsic;
    }

    /// # Summary
    /// Returns the hyperbolic cosine of the specified angle.
    ///
    /// # Remarks
    /// See [System.Math.Cosh](https://docs.microsoft.com/dotnet/api/system.math.cosh) for more details.
    function Cosh (d : Double) : Double {
        body intrinsic;
    }

    /// # Summary
    /// Returns the sine of the specified angle.
    ///
    /// # Remarks
    /// See [System.Math.Sin](https://docs.microsoft.com/dotnet/api/system.math.sin) for more details.
    function Sin (theta : Double) : Double {
        body intrinsic;
    }

    /// # Summary
    /// Returns the hyperbolic sine of the specified angle.
    ///
    /// # Remarks
    /// See [System.Math.Sinh](https://docs.microsoft.com/dotnet/api/system.math.sinh) for more details.
    function Sinh (d : Double) : Double {
        body intrinsic;
    }

    /// # Summary
    /// Returns the tangent of the specified angle.
    ///
    /// # Remarks
    /// See [System.Math.Tan](https://docs.microsoft.com/dotnet/api/system.math.tan) for more details.
    function Tan (d : Double) : Double {
        body intrinsic;
    }

    /// # Summary
    /// Returns the hyperbolic tangent of the specified angle.
    ///
    /// # Remarks
    /// See [System.Math.Tanh](https://docs.microsoft.com/dotnet/api/system.math.tanh) for more details.
    function Tanh (d : Double) : Double {
        body intrinsic;
    }

}

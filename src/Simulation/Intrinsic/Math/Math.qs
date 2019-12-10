// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

// these are all the static methods and const fields  form System.Math class of .NET CLR
// that are not exposed as language operators and are relevant within type System.
// If there are two versions of the function for Int and Double types, the corresponding
// functions have suffix I or D. ExpD also has a suffix to avoid name clash with Primitives.Exp.

namespace Microsoft.Quantum.Math {

    /// # Summary
    /// Returns the absolute value of a double-precision floating-point number.
    ///
    /// # Remarks
    /// See [System.Math.Abs](https://docs.microsoft.com/dotnet/api/system.math.abs) for more details.
    function AbsD (a : Double) : Double {
        body intrinsic;
    }

    /// # Summary
    /// Returns the absolute value of an integer.
    ///
    /// # Remarks
    /// See [System.Math.Abs](https://docs.microsoft.com/dotnet/api/system.math.abs) for more details.
    function AbsI (a : Int) : Int {
        body intrinsic;
    }

    /// # Summary
    /// Returns the absolute value of a big integer.
    ///
    /// # Remarks
    /// See [System.Numerics.BigInteger.Abs](https://docs.microsoft.com/dotnet/api/system.numerics.biginteger.abs) for more details.
    function AbsL (a : BigInt) : BigInt {
        body intrinsic;
    }

    /// # Summary
    /// Returns the smallest integer greater than or equal to the specified number.
    ///
    /// # Remarks
    /// See [System.Math.Ceiling](https://docs.microsoft.com/dotnet/api/system.math.ceiling) for more details.
    function Ceiling (value : Double) : Int {
        body intrinsic;
    }

    /// # Summary
    /// Divides one BigInteger value by another, returns the result and the remainder as a tuple.
    ///
    /// # Remarks
    /// See [System.Numerics.BigInteger.DivRem](https://docs.microsoft.com/dotnet/api/system.numerics.biginteger.divrem) for more details.
    function DivRemL(dividend : BigInt, divisor : BigInt) : (BigInt, BigInt) {
        body intrinsic;
    }

    /// # Summary
    /// Returns $e$ raised to the specified power.
    ///
    /// # Remarks
    /// See [System.Math.Exp](https://docs.microsoft.com/dotnet/api/system.math.exp) for more details.
    function ExpD (a : Double) : Double {
        body intrinsic;
    }

    /// # Summary
    /// Returns the largest integer less than or equal to the specified number.
    ///
    /// # Remarks
    /// See [System.Math.Floor](https://docs.microsoft.com/dotnet/api/system.math.floor) for more details.
    function Floor (value : Double) : Int {
        body intrinsic;
    }


    /// # Summary
    /// Returns the remainder resulting from the division of a specified number by another specified number.
    ///
    /// # Remarks
    /// See [System.Math.IEEERemainder](https://docs.microsoft.com/dotnet/api/system.math.ieeeremainder) for more details.
    function IEEERemainder (x : Double, y : Double) : Double {
        body intrinsic;
    }


    /// # Summary
    /// Returns the natural (base $e$) logarithm of a specified number.
    ///
    /// # Remarks
    /// See [System.Math.Log](https://docs.microsoft.com/dotnet/api/system.math.log) for more details.
    function Log (input : Double) : Double {
        body intrinsic;
    }


    /// # Summary
    /// Returns the base 10 logarithm of a specified number.
    ///
    /// # Remarks
    /// See [System.Math.Log10](https://docs.microsoft.com/dotnet/api/system.math.log10) for more details.
    function Log10 (input : Double) : Double {
        body intrinsic;
    }


    /// # Summary
    /// Returns the larger of two specified numbers.
    ///
    /// # Remarks
    /// See [System.Math.Max](https://docs.microsoft.com/dotnet/api/system.math.max) for more details.
    function MaxD (a : Double, b : Double) : Double {
        body intrinsic;
    }


    /// # Summary
    /// Returns the larger of two specified numbers.
    ///
    /// # Remarks
    /// See [System.Math.Max](https://docs.microsoft.com/dotnet/api/system.math.max) for more details.
    function MaxI (a : Int, b : Int) : Int {
        body intrinsic;
    }


    /// # Summary
    /// Returns the larger of two specified numbers.
    ///
    /// # Remarks
    /// See [System.Numerics.BigInteger.Max](https://docs.microsoft.com/dotnet/api/system.numerics.biginteger.max) for more details.
    function MaxL (a : BigInt, b : BigInt) : BigInt {
        body intrinsic;
    }


    /// # Summary
    /// Returns the smaller of two specified numbers.
    ///
    /// # Remarks
    /// See [System.Math.Min](https://docs.microsoft.com/dotnet/api/system.math.min) for more details.
    function MinD (a : Double, b : Double) : Double {
        body intrinsic;
    }


    /// # Summary
    /// Returns the smaller of two specified numbers.
    ///
    /// # Remarks
    /// See [System.Math.Min](https://docs.microsoft.com/dotnet/api/system.math.min) for more details.
    function MinI (a : Int, b : Int) : Int {
        body intrinsic;
    }


    /// # Summary
    /// Returns the smaller of two specified numbers.
    ///
    /// # Remarks
    /// See [System.Numerics.BigInteger.Min](https://docs.microsoft.com/dotnet/api/system.numerics.biginteger.min) for more details.
    function MinL(a : BigInt, b : BigInt) : BigInt {
        body intrinsic;
    }


    /// # Summary
    /// Performs modular division on a number raised to the power of another number.
    ///
    /// # Remarks
    /// See [System.Numerics.BigInteger.ModPow](https://docs.microsoft.com/dotnet/api/system.numerics.biginteger.modpow) for more details.
    function ModPowL(value : BigInt, exponent : BigInt, modulus: BigInt) : BigInt {
        body intrinsic;
    }

    /// # Summary
    /// Returns the number x raised to the power y.
    ///
    /// # Remarks
    /// See [System.Math.Pow](https://docs.microsoft.com/dotnet/api/system.math.pow) for more details.
    function PowD (x : Double, y : Double) : Double {
        body intrinsic;
    }


    /// # Summary
    /// Rounds a value to the nearest integer.
    ///
    /// # Remarks
    /// See [System.Math.Round](https://docs.microsoft.com/dotnet/api/system.math.round) for more details.
    function Round (a : Double) : Int {
        body intrinsic;
    }

    /// # Summary
    /// Returns an integer that indicates the sign of a number.
    ///
    /// # Remarks
    /// See [System.Math.Sign](https://docs.microsoft.com/dotnet/api/system.math.sign) for more details.
    function SignD (a : Double) : Int {
        body intrinsic;
    }


    /// # Summary
    /// Returns an integer that indicates the sign of a number.
    ///
    /// # Remarks
    /// See [System.Math.Sign](https://docs.microsoft.com/dotnet/api/system.math.sign) for more details.
    function SignI (a : Int) : Int {
        body intrinsic;
    }


    /// # Summary
    /// Returns an integer that indicates the sign of a number.
    ///
    /// # Remarks
    /// See [System.Math.Sign](https://docs.microsoft.com/dotnet/api/system.math.sign) for more details.
    function SignL (a : BigInt) : Int {
        body intrinsic;
    }

    /// # Summary
    /// Returns the square root of a specified number.
    ///
    /// # Remarks
    /// See [System.Math.Sqrt](https://docs.microsoft.com/dotnet/api/system.math.sqrt) for more details.
    function Sqrt (d : Double) : Double {
        body intrinsic;
    }

    /// # Summary
    /// Calculates the integral part of a number.
    ///
    /// # Remarks
    /// See [System.Math.Truncate](https://docs.microsoft.com/dotnet/api/system.math.truncate) for more details.
    function Truncate (a : Double) : Int {
        body intrinsic;
    }

}



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
    /// # Input
    /// ## a
    /// The number whose absolute value is to be returned.
    ///
    /// # Output
    /// The absolute value of `a`.
    ///
    /// # Example
    /// ```qsharp
    /// Message($"{AbsD(3.14)}");   // 3.14
    /// Message($"{AbsD(-2.71)}");  // 2.71
    /// ```
    ///
    /// # See Also
    /// - Microsoft.Quantum.Math.AbsI
    /// - Microsoft.Quantum.Math.AbsL
    function AbsD (a : Double) : Double {
        return a < 0.0 ? -a | a;
    }

    /// # Summary
    /// Returns the absolute value of an integer.
    ///
    /// # Input
    /// ## a
    /// The number whose absolute value is to be returned.
    ///
    /// # Output
    /// The absolute value of `a`.
    ///
    /// # Example
    /// ```qsharp
    /// Message($"{AbsD(314)}");   // 314
    /// Message($"{AbsD(-271)}");  // 271
    /// ```
    ///
    /// # See Also
    /// - Microsoft.Quantum.Math.AbsD
    /// - Microsoft.Quantum.Math.AbsL
    function AbsI (a : Int) : Int {
        return a < 0 ? -a | a;
    }

    /// # Summary
    /// Returns the absolute value of an integer.
    ///
    /// # Input
    /// ## a
    /// The number whose absolute value is to be returned.
    ///
    /// # Output
    /// The absolute value of `a`.
    ///
    /// # Example
    /// ```qsharp
    /// Message($"{AbsD(314L)}");   // 314L
    /// Message($"{AbsD(-271L)}");  // 271L
    /// ```
    ///
    /// # See Also
    /// - Microsoft.Quantum.Math.AbsD
    /// - Microsoft.Quantum.Math.AbsI
    function AbsL (a : BigInt) : BigInt {
        return a < 0L ? -a | a;
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
    /// Returns the natural logarithmic base raised to a specified power.
    ///
    /// # Input
    /// ## a
    /// The power to which $e$ should be raised.
    ///
    /// # Output
    /// The natural logarithmic base raised to the power `a`, $e^a$.
    ///
    /// # Remarks
    /// Note that on some execution targets, this function may be implemented
    /// by a limited-precision algorithm.
    function ExpD (a : Double) : Double {
        return E() ^ a;
    }

    /// # Summary
    /// Returns the remainder resulting from the division of a specified number by another specified number.
    ///
    /// # Remarks
    /// See [System.Math.IEEERemainder](https://docs.microsoft.com/dotnet/api/system.math.ieeeremainder) for more details.
    function IEEERemainder(x : Double, y : Double) : Double {
        body intrinsic;
    }


    /// # Summary
    /// Returns the natural (base $e$) logarithm of a specified number.
    ///
    /// # Remarks
    /// See [System.Math.Log](https://docs.microsoft.com/dotnet/api/system.math.log) for more details.
    function Log(input : Double) : Double {
        body intrinsic;
    }


    /// # Summary
    /// Returns the base-10 logarithm of a specified number.
    ///
    /// # Input
    /// ## input
    /// The non-negative number whose base-10 logarithm is to be computed.
    ///
    /// # Output
    /// The base-10 logarithm of `input`, such that `PowD(10.0, Log10(input))`
    /// is approximately the same as `input`.
    ///
    /// # Remarks
    /// Note that on some execution targets, this function may be implemented
    /// by a limited-precision algorithm.
    function Log10(input : Double) : Double {
        let log10 = Log(10.0);
        return Log(input) / log10;
    }


    /// # Summary
    /// Returns the larger of two specified numbers.
    ///
    /// # Input
    /// ## a
    /// The first number to be compared.
    /// ## b
    /// The second number to be compared.
    ///
    /// # Output
    /// The larger of `a` and `b`.
    ///
    /// # Example
    /// ```qsharp
    /// let max = MaxD(3.14, 2.71);  // 3.14
    /// ```
    ///
    /// # See Also
    /// - Microsoft.Quantum.MaxI
    /// - Microsoft.Quantum.MaxL
    function MaxD(a : Double, b : Double) : Double {
        return a > b ? a | b;
    }


    /// # Summary
    /// Returns the larger of two specified numbers.
    ///
    /// # Input
    /// ## a
    /// The first number to be compared.
    /// ## b
    /// The second number to be compared.
    ///
    /// # Output
    /// The larger of `a` and `b`.
    ///
    /// # Example
    /// ```qsharp
    /// let max = MaxD(314, 271);  // 314
    /// ```
    ///
    /// # See Also
    /// - Microsoft.Quantum.MaxD
    /// - Microsoft.Quantum.MaxL
    function MaxI(a : Int, b : Int) : Int {
        return a > b ? a | b;
    }


    /// # Summary
    /// Returns the larger of two specified numbers.
    ///
    /// # Input
    /// ## a
    /// The first number to be compared.
    /// ## b
    /// The second number to be compared.
    ///
    /// # Output
    /// The larger of `a` and `b`.
    ///
    /// # Example
    /// ```qsharp
    /// let max = MaxD(314L, 271L);  // 314L
    /// ```
    ///
    /// # See Also
    /// - Microsoft.Quantum.MaxD
    /// - Microsoft.Quantum.MaxI
    function MaxL (a : BigInt, b : BigInt) : BigInt {
        return a > b ? a | b;
    }


    /// # Summary
    /// Returns the smaller of two specified numbers.
    ///
    /// # Input
    /// ## a
    /// The first number to be compared.
    /// ## b
    /// The second number to be compared.
    ///
    /// # Output
    /// The smaller of `a` and `b`.
    ///
    /// # Example
    /// ```qsharp
    /// let min = MinD(3.14, 2.71);  // 2.71
    /// ```
    ///
    /// # See Also
    /// - Microsoft.Quantum.MinI
    /// - Microsoft.Quantum.MinL
    function MinD (a : Double, b : Double) : Double {
        return a < b ? a | b;
    }


    /// # Summary
    /// Returns the smaller of two specified numbers.
    ///
    /// # Input
    /// ## a
    /// The first number to be compared.
    /// ## b
    /// The second number to be compared.
    ///
    /// # Output
    /// The smaller of `a` and `b`.
    ///
    /// # Example
    /// ```qsharp
    /// let min = MinD(314, 271);  // 271
    /// ```
    ///
    /// # See Also
    /// - Microsoft.Quantum.MinD
    /// - Microsoft.Quantum.MinL
    function MinI (a : Int, b : Int) : Int {
        return a < b ? a | b;
    }


    /// # Summary
    /// Returns the smaller of two specified numbers.
    ///
    /// # Input
    /// ## a
    /// The first number to be compared.
    /// ## b
    /// The second number to be compared.
    ///
    /// # Output
    /// The smaller of `a` and `b`.
    ///
    /// # Example
    /// ```qsharp
    /// let min = MinD(314L, 271L);  // 271L
    /// ```
    ///
    /// # See Also
    /// - Microsoft.Quantum.MinD
    /// - Microsoft.Quantum.MinI
    function MinL(a : BigInt, b : BigInt) : BigInt {
        return a < b ? a | b;
    }


    /// # Summary
    /// Performs modular division on a number raised to the power of another number.
    ///
    /// # Input
    /// ## value
    /// The value to be raised to the given exponent.
    /// ## exponent
    /// The exponent to which `value` is to be raised.
    /// ## modulus
    /// The modulus with respect to which `value ^ exponent` is to be computed.
    ///
    /// # Output
    /// The result of `(value ^ exponent) % modulus`.
    ///
    /// # Remarks
    /// The implementation of this function takes the modulus at each step,
    /// making it much more efficient than `(value ^ exponent) % modulus` for
    /// large values of `value` and `exponent`.
    ///
    /// # Example
    /// The following snippet computs $11^31415 \bmod 13$:
    /// ```qsharp
    /// let result = ModPowL(11, 31415, 13);  // 6
    /// ```
    function ModPowL(value : BigInt, exponent : BigInt, modulus : BigInt) : BigInt {
        // We implement our own binary exponentiation algorithm here so that
        // we can take the modulus at every step, avoiding any large
        // intermediate values.
        mutable result = 1L;
        mutable runningExponent = exponent;
        mutable runningValue = value;
        while runningExponent > 0 {
            if (runningExponent &&& 1) {
                set result = (result * runningValue) % modulus;
            }

            set runningValue *= runningValue;
            set runningExponent >>>= 1;
        }
        return result;
    }

    /// # Summary
    /// Returns the number x raised to the power y.
    ///
    /// # Input
    /// ## x
    /// The base to be raised to the given power.
    /// ## y
    /// The power to which the base is to be raised.
    ///
    /// # Output
    /// The base `x` raised to the power `y`; i.e.: `x ^ y`.
    function PowD(x : Double, y : Double) : Double {
        return x ^ y;
    }

    /// # Summary
    /// Returns an integer that indicates the sign of a number.
    ///
    /// # Input
    /// ## a
    /// The number whose sign is to be returned.
    ///
    /// # Output
    /// The sign of `a` represented as an integer, as shown in the following
    /// table:
    ///
    /// |Return value  |Meaning                  |
    /// |--------------|-------------------------|
    /// | -1           |`a` is less than zero    |
    /// | 0            |`a` is equal to zero     |
    /// | +1           |`a` is greater than zero |
    ///
    /// # See Also
    /// - Microsoft.Quantum.Math.SignI
    /// - Microsoft.Quantum.Math.SignL
    function SignD (a : Double) : Int {
        if   (a < 0.0) { return -1; }
        elif (a > 0.0) { return +1; }
        else           { return  0; }
    }


    /// # Summary
    /// Returns an integer that indicates the sign of a number.
    ///
    /// # Input
    /// ## a
    /// The number whose sign is to be returned.
    ///
    /// # Output
    /// The sign of `a` represented as an integer, as shown in the following
    /// table:
    ///
    /// |Return value  |Meaning                  |
    /// |--------------|-------------------------|
    /// | -1           |`a` is less than zero    |
    /// | 0            |`a` is equal to zero     |
    /// | +1           |`a` is greater than zero |
    ///
    /// # See Also
    /// - Microsoft.Quantum.Math.SignD
    /// - Microsoft.Quantum.Math.SignL
    function SignI (a : Int) : Int {
        if   (a < 0) { return -1; }
        elif (a > 0) { return +1; }
        else         { return  0; }
    }


    /// # Summary
    /// Returns an integer that indicates the sign of a number.
    ///
    /// # Input
    /// ## a
    /// The number whose sign is to be returned.
    ///
    /// # Output
    /// The sign of `a` represented as an integer, as shown in the following
    /// table:
    ///
    /// |Return value  |Meaning                  |
    /// |--------------|-------------------------|
    /// | -1           |`a` is less than zero    |
    /// | 0            |`a` is equal to zero     |
    /// | +1           |`a` is greater than zero |
    ///
    /// # See Also
    /// - Microsoft.Quantum.Math.SignD
    /// - Microsoft.Quantum.Math.SignI
    function SignL (a : BigInt) : Int {
        if   (a < 0L) { return -1; }
        elif (a > 0L) { return +1; }
        else          { return  0; }
    }

    /// # Summary
    /// Returns the square root of a specified number.
    ///
    /// # Remarks
    /// See [System.Math.Sqrt](https://docs.microsoft.com/dotnet/api/system.math.sqrt) for more details.
    function Sqrt (d : Double) : Double {
        body intrinsic;
    }

    // Design notes:
    // In order to minimize the number of intrinsic functions needed in
    // runtime interfaces, we want to express Ceiling, Floor, Round, and
    // Truncate all in terms of a single intrinsic, Truncate. The differences
    // between the behavior for each can be replicated by using the output
    // of Truncate, the difference between the input and Truncate, and the
    // sign of the input:
    //
    // | Input | Truncate | Ceiling | Floor | Round |
    // |-------|----------|---------|-------|-------|
    // |   3.1 |      3.0 |     4.0 |   3.0 |   3.0 |
    // |   3.7 |      3.0 |     4.0 |   3.0 |   4.0 |
    // |  -3.1 |     -3.0 |    -3.0 |  -4.0 |  -3.0 |
    // |  -3.7 |     -3.0 |    -3.0 |  -4.0 |  -4.0 |

    /// # Summary
    /// Returns the integral part of a number.
    ///
    /// # Input
    /// ## a
    /// The value whose truncation is to be returned.
    ///
    /// # Output
    /// The truncation of the input.
    ///
    /// # Example
    /// ```
    /// Message($"{Truncate(3.1)}");   //  3.0
    /// Message($"{Truncate(3.7)}");   //  3.0
    /// Message($"{Truncate(-3.1)}");  // -3.0
    /// Message($"{Truncate(-3.7)}");  // -3.0
    /// ```
    function Truncate(a : Double) : Int {
        body intrinsic;
    }

    internal function ExtendedTruncation(value : Double) : (Int, Double, Bool) {
        let truncated = Truncate(value);
        return (truncated, truncated - value, value >= 0);
    }

    /// # Summary
    /// Returns the smallest integer greater than or equal to the specified number.
    ///
    /// # Input
    /// ## a
    /// The value whose ceiling is to be returned.
    ///
    /// # Output
    /// The ceiling of the input.
    ///
    /// # Example
    /// ```
    /// Message($"{Ceiling(3.1)}");   //  4.0
    /// Message($"{Ceiling(3.7)}");   //  4.0
    /// Message($"{Ceiling(-3.1)}");  // -3.0
    /// Message($"{Ceiling(-3.7)}");  // -3.0
    /// ```
    function Ceiling(value : Double) : Int {
        let (truncated, remainder, isPositive) = ExtendedTruncation(value);
        if AbsD(remainder) <= 1e-15 {
            return truncated;
        } else {
            return isPositive ? truncated + 1 | truncated;
        }
    }

    /// # Summary
    /// Returns the smallest integer greater than or equal to the specified number.
    ///
    /// # Input
    /// ## a
    /// The value whose floor is to be returned.
    ///
    /// # Output
    /// The floor of the input.
    ///
    /// # Example
    /// ```
    /// Message($"{Floor(3.1)}");   //  3.0
    /// Message($"{Floor(3.7)}");   //  3.0
    /// Message($"{Floor(-3.1)}");  // -4.0
    /// Message($"{Floor(-3.7)}");  // -4.0
    /// ```
    function Floor(a : Double) : Int {
        let (truncated, remainder, isPositive) = ExtendedTruncation(value);
        if AbsD(remainder) <= 1e-15 {
            return truncated;
        } else {
            return isPositive ? truncated + 1 | truncated;
        }
    }

    /// # Summary
    /// Returns the nearest integer to the specified number.
    ///
    /// # Input
    /// ## a
    /// The value to be rounded.
    ///
    /// # Output
    /// The nearest integer to the input.
    ///
    /// # Example
    /// ```
    /// Message($"{Round(3.1)}");   //  3.0
    /// Message($"{Round(3.7)}");   //  4.0
    /// Message($"{Round(-3.1)}");  // -3.0
    /// Message($"{Round(-3.7)}");  // -4.0
    /// ```
    function Round(value : Double) : Int {
        let (truncated, remainder, isPositive) = ExtendedTruncation(value);
        if AbsD(remainder) <= 1e-15 {
            return truncated;
        } else {
            let abs = AbsD(remainder);
            return truncated + (abs <= 0.5 ? 0 | (isPositive ? 1 | -1));
        }
    }


}



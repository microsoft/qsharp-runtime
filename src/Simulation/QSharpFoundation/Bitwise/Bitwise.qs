// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Bitwise {

    /// # Summary
    /// Returns the bitwise exclusive-OR (XOR) of two integers.
    /// This performs the same computation as the built-in `^^^` operator.
    ///
    /// # Example
    /// ```qsharp
    /// let a = 248;       //                 11111000₂
    /// let b = 63;        //                 00111111₂
    /// let x = Xor(a, b); // x : Int = 199 = 11000111₂.
    /// ```
    ///
    /// # Remarks
    /// See the [C# ^ Operator](https://docs.microsoft.com/dotnet/csharp/language-reference/operators/xor-operator) for more details.
    function Xor (a : Int, b : Int) : Int {
        return a ^^^ b;
    }


    /// # Summary
    /// Returns the bitwise AND of two integers.
    /// This performs the same computation as the built-in `&&&` operator.
    ///
    /// # Example
    /// ```qsharp
    /// let a = 248;       //                11111000₂
    /// let b = 63;        //                00111111₂
    /// let x = And(a, b); // x : Int = 56 = 00111000₂.
    /// ```
    ///
    /// # Remarks
    /// See the [C# &amp; Operator](https://docs.microsoft.com/dotnet/csharp/language-reference/operators/and-operator) (binary) for more details.
    function And (a : Int, b : Int) : Int {
        return a &&& b;
    }


    /// # Summary
    /// Returns the bitwise OR of two integers.
    /// This performs the same computation as the built-in `|||` operator.
    ///
    /// # Example
    /// ```qsharp
    /// let a = 248;      //                 11111000₂
    /// let b = 63;       //                 00111111₂
    /// let x = Or(a, b); // x : Int = 255 = 11111111₂.
    /// ```
    ///
    /// # Remarks
    /// See the [C# | Operator](https://docs.microsoft.com/dotnet/csharp/language-reference/operators/or-operator) for more details.
    function Or (a : Int, b : Int) : Int {
        return a ||| b;
    }


    /// # Summary
    /// Returns the bitwise NOT of an integer.
    /// This performs the same computation as the built-in `~~~` operator.
    ///
    /// # Example
    /// ```qsharp
    /// let a = 248;
    /// let x = Not(a); // x : Int = -249, due to two's complement representation.
    /// ```
    ///
    /// # Remarks
    /// See the [C# ~ Operator](https://docs.microsoft.com/dotnet/csharp/language-reference/operators/bitwise-complement-operator) for more details.
    function Not (a : Int) : Int {
        return ~~~a;
    }


    /// # Summary
    /// Returns the bitwise PARITY of an integer (1 if its binary representation contains odd number of ones and 0 otherwise).
    ///
    /// # Example
    /// ```qsharp
    /// let a = 248;
    /// let x = Parity(a); // x : Int = 1.
    /// ```
    function Parity (a : Int) : Int {
        body intrinsic;
    }

    // Common implementation for XBits and ZBits.
    internal function XOrZBits(x : Bool, paulis : Pauli[]) : Int {
        if Length(paulis) > 63 {
            fail $"Cannot represent an array of length {Length(paulis)} as an integer; at most 63 Pauli operators can be represented.";
        }

        let p = x ? PauliX | PauliZ;
        mutable result = 0;
        for pauli in paulis[Length(paulis) - 1..-1..0] {
            if pauli == p or pauli == PauliY {
                set result |||= 1;
            }
            set result <<<= 1;
        }
        return result;
    }

    /// # Summary
    /// Returns an integer representing the X bits of an array
    /// of Pauli operators.
    ///
    /// # Input
    /// ## paulis
    /// An array of Pauli operators to be represented as an integer.
    ///
    /// # Output
    /// An integer $x$ with binary representation $(p_{62}\,p_{61}\,\dots\,p_0)$,
    /// where $p_i = 0$ if `paulis[i]` is `PauliI` or `PauliZ` and where
    /// $p_i = 1$ if `paulis[i]` is `PauliX` or `PauliY`.
    ///
    /// # Remarks
    /// The function will throw if the length of `paulis` array is greater than 63.
    ///
    /// # See Also
    /// - ZBits
    function XBits (paulis : Pauli[]) : Int {
        return XOrZBits(true, paulis);
    }

    /// # Summary
    /// Returns an integer representing the Z bits of an array
    /// of Pauli operators.
    ///
    /// # Input
    /// ## paulis
    /// An array of Pauli operators to be represented as an integer.
    ///
    /// # Output
    /// An integer $x$ with binary representation $(p_{62}\,p_{61}\,\dots\,p_0)$,
    /// where $p_i = 0$ if `paulis[i]` is `PauliI` or `PauliX` and where
    /// $p_i = 1$ if `paulis[i]` is `PauliY` or `PauliZ`.
    ///
    /// # Remarks
    /// The function will throw if the length of `paulis` array is greater than 63.
    ///
    /// # See Also
    /// - XBits
    function ZBits (paulis : Pauli[]) : Int {
        return XOrZBits(false, paulis);
    }

}

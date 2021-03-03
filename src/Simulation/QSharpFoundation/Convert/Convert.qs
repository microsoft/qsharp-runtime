// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

/// # Summary
/// These are some of the functions from System.Convert namespace of .NET CLR
/// that are relevant within Q# type system.
///
/// # Remarks
/// If there are several versions of the function for Bool, Int and Double types, the corresponding
/// functions have suffix B,I and D.
namespace Microsoft.Quantum.Convert {

    /// # Summary
    /// Converts a given integer to an equivalent double-precision
    /// floating-point number.
    ///
    /// # Remarks
    /// See [C# Convert.ToDouble](https://docs.microsoft.com/dotnet/api/system.convert.todouble?view=netframework-4.7.1#System_Convert_ToDouble_System_Int64_) for more details.
    function IntAsDouble(a : Int) : Double {
        body intrinsic;
    }

    /// # Summary
    /// Converts a floating-point number to an integer by
    /// returning the truncation to its integral part.
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
    ///
    /// # See Also
    /// - Microsoft.Quantum.Math.Truncate
    /// - Microsoft.Quantum.Math.Ceiling
    /// - Microsoft.Quantum.Math.Floor
    /// - Microsoft.Quantum.Math.Round
    function DoubleAsInt(a : Double) : Int {
        body intrinsic;
    }


    /// # Summary
    /// Converts a given integer to an equivalent big integer.
    ///
    /// # Remarks
    /// See [C# BigInteger constructor](https://docs.microsoft.com/dotnet/api/system.numerics.biginteger.-ctor?view=netframework-4.7.2#System_Numerics_BigInteger__ctor_System_Int64_) for more details.
    function IntAsBigInt(a : Int) : BigInt {
        body intrinsic;
    }


    /// # Summary
    /// Converts a given big integer to an equivalent integer, if possible.
    /// The function returns a pair of the resulting integer and a Boolean flag
    /// which is true, if and only if the conversion was possible.
    /// # Remarks
    /// See [C# BigInteger constructor](https://docs.microsoft.com/dotnet/api/system.numerics.biginteger.-ctor?view=netframework-4.7.2#System_Numerics_BigInteger__ctor_System_Int64_) for more details.
    function MaybeBigIntAsInt(a : BigInt) : (Int, Bool) {
        body intrinsic;
    }


    /// # Summary
    /// Converts a given big integer to an array of Booleans.
    /// The 0 element of the array is the least significant bit of the big integer.
    /// # Remarks
    /// See [C# BigInteger constructor](https://docs.microsoft.com/dotnet/api/system.numerics.biginteger.-ctor?view=netframework-4.7.2#System_Numerics_BigInteger__ctor_System_Int64_) for more details.
    function BigIntAsBoolArray(a : BigInt) : Bool[] {
        body intrinsic;
    }


    /// # Summary
    /// Converts a given array of Booleans to an equivalent big integer.
    /// The 0 element of the array is the least significant bit of the big integer.
    /// # Remarks
    /// See [C# BigInteger constructor](https://docs.microsoft.com/dotnet/api/system.numerics.biginteger.-ctor?view=netframework-4.7.2#System_Numerics_BigInteger__ctor_System_Int64_) for more details.
    function BoolArrayAsBigInt(a : Bool[]) : BigInt {
        body intrinsic;
    }

    /// # Summary
    /// Converts a given boolean value to an equivalent string representation.
    ///
    /// # Remarks
    /// See [C# Convert.ToString](https://docs.microsoft.com/dotnet/api/system.convert.tostring?view=netframework-4.7.1#System_Convert_ToString_System_Boolean_) for more details.
    function BoolAsString(a : Bool) : String {
        return $"{a}";
    }


    /// # Summary
    /// Converts a given double-precision floating-point number to an equivalent string representation.
    ///
    /// # Remarks
    /// See [C# Convert.ToString](https://docs.microsoft.com/dotnet/api/system.convert.tostring?view=netframework-4.7.1#System_Convert_ToString_System_Double_) for more details.
    function DoubleAsString(a : Double) : String {
        return $"{a}";
    }


    /// # Summary
    /// Converts a given double-precision floating-point number to an equivalent string representation,
    /// using the given format.
    ///
    /// # Remarks
    /// See [C# Double.ToString](https://docs.microsoft.com/dotnet/api/system.double.tostring?view=netframework-4.7.1#System_Double_ToString_System_String_) for more details.
    function DoubleAsStringWithFormat(a : Double, fmt : String) : String {
        body intrinsic;
    }


    /// # Summary
    /// Converts a given integer number to an equivalent string representation.
    ///
    /// # Remarks
    /// See [C# Convert.ToString](https://docs.microsoft.com/dotnet/api/system.convert.tostring?view=netframework-4.7.1#System_Convert_ToString_System_Int64_) for more details.
    function IntAsString(a : Int) : String {
        return $"{a}";
    }

    /// # Summary
    /// Converts a given integer number to an equivalent string representation,
    /// using the given format.
    ///
    /// # Remarks
    /// See [C# Int64.ToString](https://docs.microsoft.com/dotnet/api/system.int64.tostring?view=netframework-4.7.1#System_Int64_ToString_System_String_) for more details.
    function IntAsStringWithFormat(a : Int, fmt : String) : String {
        body intrinsic;
    }

    /// # Summary
    /// Encodes a multi-qubit Pauli operator represented as an array of
    /// single-qubit Pauli operators into an integer.
    ///
    /// # Input
    /// ## paulis
    /// An array of at most 31 single-qubit Pauli operators.
    ///
    /// # Output
    /// An integer uniquely identifying `paulis`, as described below.
    ///
    /// # Remarks
    /// Each Pauli operator can be encoded using two bits:
    /// $$
    /// \begin{align}
    ///     \boldone \mapsto 00, \quad X \mapsto 01, \quad Y \mapsto 11,
    ///     \quad Z \mapsto 10.
    /// \end{align}
    /// $$
    ///
    /// Given an array of Pauli operators `[P0, ..., Pn]`, this function returns an
    /// integer with binary expansion formed by concatenating
    /// the mappings of each Pauli operator in big-endian order
    /// `bits(Pn) ... bits(P0)`.
    function PauliArrayAsInt(paulis : Pauli[]) : Int {
        let len = Length(paulis);
        if len > 31 {
            fail $"Cannot pack bits of Pauli array longer than 31 (got {len}).";
        }

        mutable result = 0;
        for p in paulis[(len-1)..-1..0] {
            set result <<<= 2;
            if   p == PauliI { set result += 0; }
            elif p == PauliX { set result += 1; }
            elif p == PauliY { set result += 3; }
            elif p == PauliZ { set result += 2; }
            else { fail $"Unexpected Pauli value {p}."; }
        }
        return result;
    }

}


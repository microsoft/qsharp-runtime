// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

/// # Summary
/// These are some of the functions from System.Convert namespace of .NET CLR
/// that are relevant within Q# type system.
///
/// # Remarks
/// If there are several versions of the function for Bool, Int and Double types, the corresponding
/// functions have suffix B,I and D.
namespace Microsoft.Quantum.Extensions.Convert {
    
    /// # Deprecated
    /// Please use @"microsoft.quantum.convert.intasdouble".
    @Deprecated ("Microsoft.Quantum.Convert.IntAsDouble")
    function ToDouble (a : Int) : Double {
        return Microsoft.Quantum.Convert.IntAsDouble(a);
    }
    
    
    /// # Deprecated
    /// Please use @"microsoft.quantum.convert.intasbigint".
    @Deprecated ("Microsoft.Quantum.Convert.IntAsBigInt")
    function ToBigInt (a : Int) : BigInt {
        return Microsoft.Quantum.Convert.IntAsBigInt(a);
    }
    
    /// # Deprecated
    /// Please use @"microsoft.quantum.convert.bigintasboolarray".
    @Deprecated ("Microsoft.Quantum.Convert.BigIntAsBoolArray")
    function BigIntToBools (a : BigInt) : Bool[] {
        return Microsoft.Quantum.Convert.BigIntAsBoolArray(a);
    }
    
    /// # Deprecated
    /// Please use @"microsoft.quantum.convert.boolarrayasbigint".
    @Deprecated ("Microsoft.Quantum.Convert.BoolArrayAsBigInt")
    function BoolsToBigInt (a : Bool[]) : BigInt {
        return Microsoft.Quantum.Convert.BoolArrayAsBigInt(a);
    }
    
    /// # Deprecated
    /// Please use @"microsoft.quantum.convert.boolasstring".
    @Deprecated ("Microsoft.Quantum.Convert.BoolAsString")
    function ToStringB (a : Bool) : String {
        return Microsoft.Quantum.Convert.BoolAsString(a);
    }    
    
    /// # Deprecated
    /// Please use @"microsoft.quantum.convert.doubleasstring".
    @Deprecated ("Microsoft.Quantum.Convert.DoubleAsString")
    function ToStringD (a : Double) : String {
        return Microsoft.Quantum.Convert.DoubleAsString(a);
    }
    
    /// # Deprecated
    /// Please use @"microsoft.quantum.convert.doubleasstringwithformat".
    @Deprecated ("Microsoft.Quantum.Convert.DoubleAsStringWithFormat")
    function ToStringDFormat (a : Double, fmt : String) : String {
        return Microsoft.Quantum.Convert.DoubleAsStringWithFormat(a, fmt);
    }
    
    /// # Deprecated
    /// Please use @"microsoft.quantum.convert.intasstring".
    @Deprecated ("Microsoft.Quantum.Convert.IntAsString")
    function ToStringI (a : Int) : String {
        return Microsoft.Quantum.Convert.IntAsString(a);
    }
    
    /// # Deprecated
    /// Please use @"microsoft.quantum.convert.intasstringwithformat".
    @Deprecated ("Microsoft.Quantum.Convert.IntAsStringWithFormat")
    function ToStringIFormat (a : Int, fmt : String) : String {
        return Microsoft.Quantum.Convert.IntAsStringWithFormat(a, fmt);
    }
    
    /// # Deprecated
    /// Please use @"microsoft.quantum.convert.pauliarrayasint".
    @Deprecated ("Microsoft.Quantum.Convert.PauliArrayAsInt")
    function PauliArrayToInt (paulis : Pauli[]) : Int {
        return Microsoft.Quantum.Convert.PauliArrayAsInt(paulis);
    }
    
}



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
    open Microsoft.Quantum.Warnings;
    
    /// # Deprecated
    /// Please use @"microsoft.quantum.convert.intasdouble".
    function ToDouble (a : Int) : Double {
        _Renamed("Microsoft.Quantum.Extensions.Convert.ToDouble", "Microsoft.Quantum.Convert.IntAsDouble");
        return Microsoft.Quantum.Convert.IntAsDouble(a);
    }
    
    
    /// # Deprecated
    /// Please use @"microsoft.quantum.convert.intasbigint".
    function ToBigInt (a : Int) : BigInt {
        _Renamed("Microsoft.Quantum.Extensions.Convert.ToBigInt", "Microsoft.Quantum.Convert.IntAsBigInt");
        return Microsoft.Quantum.Convert.IntAsBigInt(a);
    }
    
    /// # Deprecated
    /// Please use @"microsoft.quantum.convert.bigintasboolarray".
    function BigIntToBools (a : BigInt) : Bool[] {
        _Renamed("Microsoft.Quantum.Extensions.Convert.BigIntToBools", "Microsoft.Quantum.Convert.BigIntAsBoolArray");
        return Microsoft.Quantum.Convert.BigIntAsBoolArray(a);
    }
    
    /// # Deprecated
    /// Please use @"microsoft.quantum.convert.boolarrayasbigint".
    function BoolsToBigInt (a : Bool[]) : BigInt {
        _Renamed("Microsoft.Quantum.Extensions.Convert.BoolsToBigInt", "Microsoft.Quantum.Convert.BoolArrayAsBigInt");
        return Microsoft.Quantum.Convert.BoolArrayAsBigInt(a);
    }
    
    /// # Deprecated
    /// Please use @"microsoft.quantum.convert.boolasstring".
    function ToStringB (a : Bool) : String {
        _Renamed("Microsoft.Quantum.Extensions.Convert.ToStringB", "Microsoft.Quantum.Convert.BoolAsString");
        return Microsoft.Quantum.Convert.BoolAsString(a);
    }    
    
    /// # Deprecated
    /// Please use @"microsoft.quantum.convert.doubleasstring".
    function ToStringD (a : Double) : String {
        _Renamed("Microsoft.Quantum.Extensions.Convert.ToStringD", "Microsoft.Quantum.Convert.DoubleAsString");
        return Microsoft.Quantum.Convert.DoubleAsString(a);
    }
    
    /// # Deprecated
    /// Please use @"microsoft.quantum.convert.doubleasstringwithformat".
    function ToStringDFormat (a : Double, fmt : String) : String {
        _Renamed("Microsoft.Quantum.Extensions.Convert.ToStringDFormat", "Microsoft.Quantum.Convert.DoubleAsStringWithFormat");
        return Microsoft.Quantum.Convert.DoubleAsStringWithFormat(a, fmt);
    }
    
    /// # Deprecated
    /// Please use @"microsoft.quantum.convert.intasstring".
    function ToStringI (a : Int) : String {
        _Renamed("Microsoft.Quantum.Extensions.Convert.ToStringI", "Microsoft.Quantum.Convert.IntAsString");
        return Microsoft.Quantum.Convert.IntAsString(a);
    }
    
    /// # Deprecated
    /// Please use @"microsoft.quantum.convert.intasstringwithformat".
    function ToStringIFormat (a : Int, fmt : String) : String {
        _Renamed("Microsoft.Quantum.Extensions.Convert.ToStringIFormat", "Microsoft.Quantum.Convert.IntAsStringWithFormat");
        return Microsoft.Quantum.Convert.IntAsStringWithFormat(a, fmt);
    }
    
    /// # Deprecated
    /// Please use @"microsoft.quantum.convert.pauliarrayasint".
    function PauliArrayToInt (paulis : Pauli[]) : Int {
        _Renamed("Microsoft.Quantum.Extensions.Convert.PauliArrayToInt", "Microsoft.Quantum.Convert.PauliArrayAsInt");
        return Microsoft.Quantum.Convert.PauliArrayAsInt(paulis);
    }
    
}



// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

// these are all the static methods and const fields  form System.Math class of .NET CLR
// that are not exposed as language operators and are relevant within type System.
// If there are two versions of the function for Int and Double types, the corresponding
// functions have suffix I or D. ExpD also has a suffix to avoid name clash with Primitives.Exp.


namespace Microsoft.Quantum.Extensions.Math {

    /// # Deprecated
    /// Please use @"microsoft.quantum.math.absd".
    @Deprecated ("Microsoft.Quantum.Math.AbsD")
    function AbsD(a : Double) : Double {
        return Microsoft.Quantum.Math.AbsD(a);
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.math.absi".
    @Deprecated ("Microsoft.Quantum.Math.AbsI")
    function AbsI(a : Int) : Int {
        return Microsoft.Quantum.Math.AbsI(a);
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.math.arccos".
    @Deprecated ("Microsoft.Quantum.Math.ArcCos")
    function ArcCos(theta : Double) : Double {
        return Microsoft.Quantum.Math.ArcCos(theta);
    }
    
    /// # Deprecated
    /// Please use @"microsoft.quantum.math.arcsin".
    @Deprecated ("Microsoft.Quantum.Math.ArcSin")
    function ArcSin(theta : Double) : Double {
        return Microsoft.Quantum.Math.ArcSin(theta);
    }
    
    /// # Deprecated
    /// Please use @"microsoft.quantum.math.arctan".
    @Deprecated ("Microsoft.Quantum.Math.ArcTan")
    function ArcTan(theta : Double) : Double {
        return Microsoft.Quantum.Math.ArcTan(theta);
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.math.arctan2".
    @Deprecated ("Microsoft.Quantum.Math.ArcTan2")
    function ArcTan2(y : Double, x : Double) : Double {
        return Microsoft.Quantum.Math.ArcTan2(y, x);
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.math.ceiling".
    @Deprecated ("Microsoft.Quantum.Math.Ceiling")
    function Ceiling(value : Double) : Int {
        return Microsoft.Quantum.Math.Ceiling(value);
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.math.cos".
    @Deprecated ("Microsoft.Quantum.Math.Cos")
    function Cos(theta : Double) : Double {
        return Microsoft.Quantum.Math.Cos(theta);
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.math.cosh".
    @Deprecated ("Microsoft.Quantum.Math.Cosh")
    function Cosh(theta : Double) : Double {
        return Microsoft.Quantum.Math.Cosh(theta);
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.math.e".
    @Deprecated ("Microsoft.Quantum.Math.E")
    function E() : Double {
        return Microsoft.Quantum.Math.E();
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.math.expd".
    @Deprecated ("Microsoft.Quantum.Math.ExpD")
    function ExpD (a : Double) : Double {
        return Microsoft.Quantum.Math.ExpD(a);
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.math.floor".
    @Deprecated ("Microsoft.Quantum.Math.Floor")
    function Floor(value : Double) : Int {
        return Microsoft.Quantum.Math.Floor(value);
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.math.ieeeremainder".
    @Deprecated ("Microsoft.Quantum.Math.IEEERemainder")
    function IEEERemainder(x : Double, y : Double) : Double {
        return Microsoft.Quantum.Math.IEEERemainder(x, y);
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.math.log".
    @Deprecated ("Microsoft.Quantum.Math.Log")
    function Log(input : Double) : Double {
        return Microsoft.Quantum.Math.Log(input);
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.math.log10".
    @Deprecated ("Microsoft.Quantum.Math.Log10")
    function Log10(input : Double) : Double {
        return Microsoft.Quantum.Math.Log10(input);
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.math.maxd".
    @Deprecated ("Microsoft.Quantum.Math.MaxD")
    function MaxD(a : Double, b : Double) : Double {
        return Microsoft.Quantum.Math.MaxD(a, b);
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.math.maxi".
    @Deprecated ("Microsoft.Quantum.Math.MaxI")
    function MaxI(a : Int, b : Int) : Int {
        return Microsoft.Quantum.Math.MaxI(a, b);
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.math.mind".
    @Deprecated ("Microsoft.Quantum.Math.MinD")
    function MinD(a : Double, b : Double) : Double {
        return Microsoft.Quantum.Math.MinD(a, b);
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.math.mini".
    @Deprecated ("Microsoft.Quantum.Math.MinI")
    function MinI(a : Int, b : Int) : Int {
        return Microsoft.Quantum.Math.MinI(a, b);
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.math.pi".
    @Deprecated ("Microsoft.Quantum.Math.PI")
    function PI() : Double {
        return Microsoft.Quantum.Math.PI();
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.math.powd".
    @Deprecated ("Microsoft.Quantum.Math.PowD")
    function PowD(x : Double, y : Double) : Double {
        return Microsoft.Quantum.Math.PowD(x, y);
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.math.round".
    @Deprecated ("Microsoft.Quantum.Math.Round")
    function Round(a : Double) : Int {
        return Microsoft.Quantum.Math.Round(a);
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.math.sin".
    @Deprecated ("Microsoft.Quantum.Math.Sin")
    function Sin(theta : Double) : Double {
        return Microsoft.Quantum.Math.Sin(theta);
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.math.signd".
    @Deprecated ("Microsoft.Quantum.Math.SignD")
    function SignD(a : Double) : Int {
        return Microsoft.Quantum.Math.SignD(a);
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.math.signi".
    @Deprecated ("Microsoft.Quantum.Math.SignI")
    function SignI(a : Int) : Int {
        return Microsoft.Quantum.Math.SignI(a);
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.math.sinh".
    @Deprecated ("Microsoft.Quantum.Math.Sinh")
    function Sinh (d : Double) : Double {
        return Microsoft.Quantum.Math.Sinh(d);
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.math.sqrt".
    @Deprecated ("Microsoft.Quantum.Math.Sqrt")
    function Sqrt (d : Double) : Double {
        return Microsoft.Quantum.Math.Sqrt(d);
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.math.tan".
    @Deprecated ("Microsoft.Quantum.Math.Tan")
    function Tan (d : Double) : Double {
        return Microsoft.Quantum.Math.Tan(d);
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.math.tanh".
    @Deprecated ("Microsoft.Quantum.Math.Tanh")
    function Tanh (d : Double) : Double {
        return Microsoft.Quantum.Math.Tanh(d);
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.math.truncate".
    @Deprecated ("Microsoft.Quantum.Math.Truncate")
    function Truncate (a : Double) : Int {
        return Microsoft.Quantum.Math.Truncate(a);
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.math.absl".
    @Deprecated ("Microsoft.Quantum.Math.AbsL")
    function AbsB (a : BigInt) : BigInt {
        return Microsoft.Quantum.Math.AbsL(a);
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.math.signl".
    @Deprecated ("Microsoft.Quantum.Math.SignL")
    function SignB (a : BigInt) : Int {
        return Microsoft.Quantum.Math.SignL(a);
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.math.maxl".
    @Deprecated ("Microsoft.Quantum.Math.MaxL")
    function MaxB (a : BigInt, b : BigInt) : BigInt {
        return Microsoft.Quantum.Math.MaxL(a, b);
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.math.minl".
    @Deprecated ("Microsoft.Quantum.Math.MinL")
    function MinB (a : BigInt, b : BigInt) : BigInt {
        return Microsoft.Quantum.Math.MinL(a, b);
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.math.divreml".
    @Deprecated ("Microsoft.Quantum.Math.DivRemL")
    function DivRemB (dividend : BigInt, divisor : BigInt) : (BigInt, BigInt) {
        return Microsoft.Quantum.Math.DivRemL(dividend, divisor);
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.math.modpowl".
    @Deprecated ("Microsoft.Quantum.Math.ModPowL")
    function ModPowB (value : BigInt, exponent : BigInt, modulus: BigInt) : BigInt {
        return Microsoft.Quantum.Math.ModPowL(value, exponent, modulus);
    }

}

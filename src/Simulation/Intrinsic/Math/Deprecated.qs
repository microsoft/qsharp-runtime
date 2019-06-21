// these are all the static methods and const fields  form System.Math class of .NET CLR
// that are not exposed as language operators and are relevant within type System.
// If there are two versions of the function for Int and Double types, the corresponding
// functions have suffix I or D. ExpD also has a suffix to avoid name clash with Primitives.Exp.


namespace Microsoft.Quantum.Extensions.Math {
    open Microsoft.Quantum.Warnings;

    /// # Deprecated
    /// Please use @"microsoft.quantum.math.absd".
    function AbsD(a : Double) : Double {
        _Renamed("Microsoft.Quantum.Extensions.Math.AbsD", "Microsoft.Quantum.Math.AbsD");
        return Microsoft.Quantum.Math.AbsD(a);
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.math.absi".
    function AbsI(a : Int) : Int {
        _Renamed("Microsoft.Quantum.Extensions.Math.AbsI", "Microsoft.Quantum.Math.AbsI");
        return Microsoft.Quantum.Math.AbsI(a);
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.math.arccos".
    function ArcCos(theta : Double) : Double {
        _Renamed("Microsoft.Quantum.Extensions.Math.ArcCos", "Microsoft.Quantum.Math.ArcCos");
        return Microsoft.Quantum.Math.ArcCos(theta);
    }
    
    /// # Deprecated
    /// Please use @"microsoft.quantum.math.arcsin".
    function ArcSin(theta : Double) : Double {
        _Renamed("Microsoft.Quantum.Extensions.Math.ArcSin", "Microsoft.Quantum.Math.ArcSin");
        return Microsoft.Quantum.Math.ArcSin(theta);
    }
    
    /// # Deprecated
    /// Please use @"microsoft.quantum.math.arctan".
    function ArcTan(theta : Double) : Double {
        _Renamed("Microsoft.Quantum.Extensions.Math.ArcTan", "Microsoft.Quantum.Math.ArcTan");
        return Microsoft.Quantum.Math.ArcTan(theta);
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.math.arctan2".
    function ArcTan2(y : Double, x : Double) : Double {
        _Renamed("Microsoft.Quantum.Extensions.Math.ArcTan2", "Microsoft.Quantum.Math.ArcTan2");
        return Microsoft.Quantum.Math.ArcTan2(y, x);
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.math.ceiling".
    function Ceiling(value : Double) : Int {
        _Renamed("Microsoft.Quantum.Extensions.Math.Ceiling", "Microsoft.Quantum.Math.Ceiling");
        return Microsoft.Quantum.Math.Ceiling(value);
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.math.cos".
    function Cos(theta : Double) : Double {
        _Renamed("Microsoft.Quantum.Extensions.Math.Cos", "Microsoft.Quantum.Math.Cos");
        return Microsoft.Quantum.Math.Cos(theta);
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.math.cosh".
    function Cosh(theta : Double) : Double {
        _Renamed("Microsoft.Quantum.Extensions.Math.Cosh", "Microsoft.Quantum.Math.Cosh");
        return Microsoft.Quantum.Math.Cosh(theta);
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.math.e".
    function E() : Double {
        _Renamed("Microsoft.Quantum.Extensions.Math.E", "Microsoft.Quantum.Math.E");
        return Microsoft.Quantum.Math.E();
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.math.expd".
    function ExpD (a : Double) : Double {
        _Renamed("Microsoft.Quantum.Extensions.Math.ExpD", "Microsoft.Quantum.Math.ExpD");
        return Microsoft.Quantum.Math.ExpD(a);
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.math.floor".
    function Floor(value : Double) : Int {
        _Renamed("Microsoft.Quantum.Extensions.Math.Floor", "Microsoft.Quantum.Math.Floor");
        return Microsoft.Quantum.Math.Floor(value);
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.math.ieeeremainder".
    function IEEERemainder(x : Double, y : Double) : Double {
        _Renamed("Microsoft.Quantum.Extensions.Math.IEEERemainder", "Microsoft.Quantum.Math.IEEERemainder");
        return Microsoft.Quantum.Math.IEEERemainder(x, y);
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.math.log".
    function Log(input : Double) : Double {
        _Renamed("Microsoft.Quantum.Extensions.Math.Log", "Microsoft.Quantum.Math.Log");
        return Microsoft.Quantum.Math.Log(input);
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.math.log10".
    function Log10(input : Double) : Double {
        _Renamed("Microsoft.Quantum.Extensions.Math.Log10", "Microsoft.Quantum.Math.Log10");
        return Microsoft.Quantum.Math.Log10(input);
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.math.maxd".
    function MaxD(a : Double, b : Double) : Double {
        _Renamed("Microsoft.Quantum.Extensions.Math.MaxD", "Microsoft.Quantum.Math.MaxD");
        return Microsoft.Quantum.Math.MaxD(a, b);
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.math.maxi".
    function MaxI(a : Int, b : Int) : Int {
        _Renamed("Microsoft.Quantum.Extensions.Math.MaxI", "Microsoft.Quantum.Math.MaxI");
        return Microsoft.Quantum.Math.MaxI(a, b);
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.math.mind".
    function MinD(a : Double, b : Double) : Double {
        _Renamed("Microsoft.Quantum.Extensions.Math.MinD", "Microsoft.Quantum.Math.MinD");
        return Microsoft.Quantum.Math.MinD(a, b);
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.math.mini".
    function MinI(a : Int, b : Int) : Int {
        _Renamed("Microsoft.Quantum.Extensions.Math.MinI", "Microsoft.Quantum.Math.MinI");
        return Microsoft.Quantum.Math.MinI(a, b);
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.math.pi".
    function PI() : Double {
        _Renamed("Microsoft.Quantum.Extensions.Math.PI", "Microsoft.Quantum.Math.PI");
        return Microsoft.Quantum.Math.PI();
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.math.powd".
    function PowD(x : Double, y : Double) : Double {
        _Renamed("Microsoft.Quantum.Extensions.Math.PowD", "Microsoft.Quantum.Math.PowD");
        return Microsoft.Quantum.Math.PowD(x, y);
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.math.round".
    function Round(a : Double) : Int {
        _Renamed("Microsoft.Quantum.Extensions.Math.Round", "Microsoft.Quantum.Math.Round");
        return Microsoft.Quantum.Math.Round(a);
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.math.sin".
    function Sin(theta : Double) : Double {
        _Renamed("Microsoft.Quantum.Extensions.Math.Sin", "Microsoft.Quantum.Math.Sin");
        return Microsoft.Quantum.Math.Sin(theta);
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.math.signd".
    function SignD(a : Double) : Int {
        _Renamed("Microsoft.Quantum.Extensions.Math.SignD", "Microsoft.Quantum.Math.SignD");
        return Microsoft.Quantum.Math.SignD(a);
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.math.signi".
    function SignI(a : Int) : Int {
        _Renamed("Microsoft.Quantum.Extensions.Math.SignI", "Microsoft.Quantum.Math.SignI");
        return Microsoft.Quantum.Math.SignI(a);
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.math.sinh".
    function Sinh (d : Double) : Double {
        _Renamed("Microsoft.Quantum.Extensions.Math.Sinh", "Microsoft.Quantum.Math.Sinh");
        return Microsoft.Quantum.Math.Sinh(d);
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.math.sqrt".
    function Sqrt (d : Double) : Double {
        _Renamed("Microsoft.Quantum.Extensions.Math.Sqrt", "Microsoft.Quantum.Math.Sqrt");
        return Microsoft.Quantum.Math.Sqrt(d);
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.math.tan".
    function Tan (d : Double) : Double {
        _Renamed("Microsoft.Quantum.Extensions.Math.Tan", "Microsoft.Quantum.Math.Tan");
        return Microsoft.Quantum.Math.Tan(d);
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.math.tanh".
    function Tanh (d : Double) : Double {
        _Renamed("Microsoft.Quantum.Extensions.Math.Tanh", "Microsoft.Quantum.Math.Tanh");
        return Microsoft.Quantum.Math.Tanh(d);
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.math.truncate".
    function Truncate (a : Double) : Int {
        _Renamed("Microsoft.Quantum.Extensions.Math.Truncate", "Microsoft.Quantum.Math.Truncate");
        return Microsoft.Quantum.Math.Truncate(a);
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.math.absl".
    function AbsB (a : BigInt) : BigInt {
        _Renamed("Microsoft.Quantum.Extensions.Math.AbsB", "Microsoft.Quantum.Math.AbsL");
        return Microsoft.Quantum.Math.AbsL(a);
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.math.signl".
    function SignB (a : BigInt) : Int {
        _Renamed("Microsoft.Quantum.Extensions.Math.SignB", "Microsoft.Quantum.Math.SignL");
        return Microsoft.Quantum.Math.SignL(a);
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.math.maxl".
    function MaxB (a : BigInt, b : BigInt) : BigInt {
        _Renamed("Microsoft.Quantum.Extensions.Math.MaxB", "Microsoft.Quantum.Math.MaxL");
        return Microsoft.Quantum.Math.MaxL(a, b);
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.math.minl".
    function MinB (a : BigInt, b : BigInt) : BigInt {
        _Renamed("Microsoft.Quantum.Extensions.Math.MinB", "Microsoft.Quantum.Math.MinL");
        return Microsoft.Quantum.Math.MinL(a, b);
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.math.divreml".
    function DivRemB (dividend : BigInt, divisor : BigInt) : (BigInt, BigInt) {
        _Renamed("Microsoft.Quantum.Extensions.Math.DivRemB", "Microsoft.Quantum.Math.DivRemL");
        return Microsoft.Quantum.Math.DivRemL(dividend, divisor);
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.math.modpowl".
    function ModPowB (value : BigInt, exponent : BigInt, modulus: BigInt) : BigInt {
        _Renamed("Microsoft.Quantum.Extensions.Math.ModPowB", "Microsoft.Quantum.Math.ModPowL");
        return Microsoft.Quantum.Math.ModPowL(value, exponent, modulus);
    }

}

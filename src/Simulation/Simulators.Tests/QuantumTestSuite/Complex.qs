// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.TestSuite.Math {
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Convert;
    
    
    newtype Complex = (Double, Double);
    
    
    function ExpIC (phi : Double) : Complex {
        
        return Complex(Cos(phi), Sin(phi));
    }
    
    
    function ExpICFrac (numerator : Int, denomPower : Int) : Complex {
        
        let denom = 2 ^ denomPower;
        let phi = IntAsDouble(numerator) / IntAsDouble(denom);
        return ExpIC(phi);
    }
    
    
    function PlusC (a : Complex, b : Complex) : Complex {
        
        let (aRe, aIm) = a!;
        let (bRe, bIm) = b!;
        return Complex(aRe + bRe, aIm + bIm);
    }
    
    
    function TimesC (a : Complex, b : Complex) : Complex {
        
        let (aRe, aIm) = a!;
        let (bRe, bIm) = b!;
        return Complex(aRe * bRe - aIm * bIm, aRe * bIm + aIm * bRe);
    }
    
    
    function ConjugateC (a : Complex) : Complex {
        
        let (aRe, aIm) = a!;
        return Complex(aRe, -aIm);
    }
    
    
    function MinusC (a : Complex) : Complex {
        
        let (aRe, aIm) = a!;
        return Complex(-aRe, -aIm);
    }
    
    
    function DivCD (a : Complex, b : Double) : Complex {
        
        let (aRe, aIm) = a!;
        return Complex(aRe / b, aIm / b);
    }
    
    
    function AbsSquaredC (a : Complex) : Double {
        
        let (aRe, aIm) = a!;
        return aRe * aRe + aIm * aIm;
    }
    
    
    function AbsC (a : Complex) : Double {
        
        return Sqrt(AbsSquaredC(a));
    }
    
    
    function DivCC (a : Complex, b : Complex) : Complex {
        
        return DivCD(TimesC(a, ConjugateC(b)), AbsSquaredC(b));
    }
    
    
    function ZeroC () : Complex {
        
        
        //TODO: BUG 799 fix this when the bug is resolved
        return Complex(0.0, 0.0);
    }
    
    
    function OneC () : Complex {
        
        
        //TODO: BUG 799 fix this when the bug is resolved
        return Complex(1.0, 0.0);
    }
    
    
    function ComplexI () : Complex {
        
        
        //TODO: BUG 799 fix this when the bug is resolved
        return Complex(0.0, 1.0);
    }
    
    
    function ComplexIPower (power : Int) : Complex {
        let powMod4 = (power % 4 + 8) % 4;
        
        if (powMod4 == 0) {
            return Complex(1.0, 0.0);
        } elif (powMod4 == 1) {
            return Complex(0.0, 1.0);
        } elif (powMod4 == 2) {
            return Complex(-1.0, 0.0);
        } elif (powMod4 == 3) {
            return Complex(0.0, -1.0);
        }
        
        fail $"this line should never be reached";
    }
    
}



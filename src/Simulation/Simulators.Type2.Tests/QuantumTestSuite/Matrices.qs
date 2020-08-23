// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.TestSuite.Math {
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Convert;
    
    
    function ExpXMatrix (phi : Double) : RowMajorMatrix {
        
        let matrix = [[Complex(Cos(phi), 0.0), Complex(0.0, Sin(phi))], [Complex(0.0, Sin(phi)), Complex(Cos(phi), 0.0)]];
        return RowMajorMatrix(matrix);
    }
    
    
    function ExpYMatrix (phi : Double) : RowMajorMatrix {
        
        let matrix = [[Complex(Cos(phi), 0.0), Complex(Sin(phi), 0.0)], [Complex(-Sin(phi), 0.0), Complex(Cos(phi), 0.0)]];
        return RowMajorMatrix(matrix);
    }
    
    
    function ExpZMatrix (phi : Double) : RowMajorMatrix {
        
        return RowMajorMatrix([[ExpIC(phi), ZeroC()], [ZeroC(), ExpIC(-phi)]]);
    }
    
    
    function ExpIMatrix (phi : Double) : RowMajorMatrix {
        
        return RowMajorMatrix([[ExpIC(phi), ZeroC()], [ZeroC(), ExpIC(phi)]]);
    }
    
    
    function ExpPauliMatrix (pauli : Pauli, phi : Double) : RowMajorMatrix {
        
        
        if (pauli == PauliI) {
            return ExpIMatrix(phi);
        }
        elif (pauli == PauliX) {
            return ExpXMatrix(phi);
        }
        elif (pauli == PauliY) {
            return ExpYMatrix(phi);
        }
        elif (pauli == PauliZ) {
            return ExpZMatrix(phi);
        }
        
        fail $"this line should never be reached";
    }
    
    
    function R1Matrix (phi : Double) : RowMajorMatrix {
        
        return RowMajorMatrix([[OneC(), ZeroC()], [ZeroC(), ExpIC(phi)]]);
    }
    
    
    function PauliMatrix (pauli : Pauli) : RowMajorMatrix {
        
        
        if (pauli == PauliI) {
            return RowMajorMatrix([[OneC(), ZeroC()], [ZeroC(), OneC()]]);
        }
        elif (pauli == PauliX) {
            return RowMajorMatrix([[ZeroC(), OneC()], [OneC(), ZeroC()]]);
        }
        elif (pauli == PauliY) {
            return RowMajorMatrix([[ZeroC(), Complex(0.0, -1.0)], [Complex(0.0, 1.0), ZeroC()]]);
        }
        elif (pauli == PauliZ) {
            return RowMajorMatrix([[OneC(), ZeroC()], [ZeroC(), MinusC(OneC())]]);
        }
        
        fail $"this line should never be reached";
    }
    
    
    function SMatrix () : RowMajorMatrix {
        
        return RowMajorMatrix([[OneC(), ZeroC()], [ZeroC(), Complex(0.0, 1.0)]]);
    }
    
    
    function TMatrix () : RowMajorMatrix {
        
        let oneOvSqrt2 = 1.0 / Sqrt(2.0);
        return RowMajorMatrix([[OneC(), ZeroC()], [ZeroC(), Complex(oneOvSqrt2, oneOvSqrt2)]]);
    }
    
    
    function HMatrix () : RowMajorMatrix {
        
        let oneOvSqrt2 = DivCD(OneC(), Sqrt(2.0));
        return RowMajorMatrix([[oneOvSqrt2, oneOvSqrt2], [oneOvSqrt2, MinusC(oneOvSqrt2)]]);
    }
    
    
    function CNOTMatrix () : RowMajorMatrix {
        
        let I = OneC();
        let O = ZeroC();
        let matrix = [
            [I, O, O, O],
            [O, O, O, I],
            [O, O, I, O],
            [O, I, O, O]
        ];
        return RowMajorMatrix(matrix);
    }
    
    
    function SWAPMatrix () : RowMajorMatrix {
        
        let I = OneC();
        let O = ZeroC();
        let matrix = [
            [I, O, O, O],
            [O, O, I, O],
            [O, I, O, O],
            [O, O, O, I]
        ];
        return RowMajorMatrix(matrix);
    }
    
    
    // All code below has been auto-generated using Mathematics notebook TestSuiteCalculations.nb
    
    function ExpIIMatrix (t : Double) : RowMajorMatrix {
        
        let O = ZeroC();
        let C = Complex(Cos(t), 0.0);
        let IS = Complex(0.0, Sin(t));
        let mIS = Complex(0.0, -Sin(t));
        let pS = Complex(Sin(t), 0.0);
        let mS = Complex(-Sin(t), 0.0);
        let Ep = ExpIC(t);
        let Em = ExpIC(-t);
        let matrix = [
            [Ep, O, O, O],
            [O, Ep, O, O],
            [O, O, Ep, O],
            [O, O, O, Ep]
        ];
        return RowMajorMatrix(matrix);
    }
    
    
    function ExpIXMatrix (t : Double) : RowMajorMatrix {
        
        let O = ZeroC();
        let C = Complex(Cos(t), 0.0);
        let IS = Complex(0.0, Sin(t));
        let mIS = Complex(0.0, -Sin(t));
        let pS = Complex(Sin(t), 0.0);
        let mS = Complex(-Sin(t), 0.0);
        let Ep = ExpIC(t);
        let Em = ExpIC(-t);
        let matrix = [
            [C, IS, O, O],
            [IS, C, O, O],
            [O, O, C, IS],
            [O, O, IS, C]
        ];
        return RowMajorMatrix(matrix);
    }
    
    
    function ExpIYMatrix (t : Double) : RowMajorMatrix {
        
        let O = ZeroC();
        let C = Complex(Cos(t), 0.0);
        let IS = Complex(0.0, Sin(t));
        let mIS = Complex(0.0, -Sin(t));
        let pS = Complex(Sin(t), 0.0);
        let mS = Complex(-Sin(t), 0.0);
        let Ep = ExpIC(t);
        let Em = ExpIC(-t);
        let matrix = [
            [C, pS, O, O],
            [mS, C, O, O],
            [O, O, C, pS],
            [O, O, mS, C]
        ];
        return RowMajorMatrix(matrix);
    }
    
    
    function ExpIZMatrix (t : Double) : RowMajorMatrix {
        
        let O = ZeroC();
        let C = Complex(Cos(t), 0.0);
        let IS = Complex(0.0, Sin(t));
        let mIS = Complex(0.0, -Sin(t));
        let pS = Complex(Sin(t), 0.0);
        let mS = Complex(-Sin(t), 0.0);
        let Ep = ExpIC(t);
        let Em = ExpIC(-t);
        let matrix = [
            [Ep, O, O, O],
            [O, Em, O, O],
            [O, O, Ep, O],
            [O, O, O, Em]
        ];
        return RowMajorMatrix(matrix);
    }
    
    
    function ExpXIMatrix (t : Double) : RowMajorMatrix {
        
        let O = ZeroC();
        let C = Complex(Cos(t), 0.0);
        let IS = Complex(0.0, Sin(t));
        let mIS = Complex(0.0, -Sin(t));
        let pS = Complex(Sin(t), 0.0);
        let mS = Complex(-Sin(t), 0.0);
        let Ep = ExpIC(t);
        let Em = ExpIC(-t);
        let matrix = [
            [C, O, IS, O],
            [O, C, O, IS],
            [IS, O, C, O],
            [O, IS, O, C]
        ];
        return RowMajorMatrix(matrix);
    }
    
    
    function ExpXXMatrix (t : Double) : RowMajorMatrix {
        
        let O = ZeroC();
        let C = Complex(Cos(t), 0.0);
        let IS = Complex(0.0, Sin(t));
        let mIS = Complex(0.0, -Sin(t));
        let pS = Complex(Sin(t), 0.0);
        let mS = Complex(-Sin(t), 0.0);
        let Ep = ExpIC(t);
        let Em = ExpIC(-t);
        let matrix = [
            [C, O, O, IS],
            [O, C, IS, O],
            [O, IS, C, O], 
            [IS, O, O, C]
        ];
        return RowMajorMatrix(matrix);
    }
    
    
    function ExpXYMatrix (t : Double) : RowMajorMatrix {
        
        let O = ZeroC();
        let C = Complex(Cos(t), 0.0);
        let IS = Complex(0.0, Sin(t));
        let mIS = Complex(0.0, -Sin(t));
        let pS = Complex(Sin(t), 0.0);
        let mS = Complex(-Sin(t), 0.0);
        let Ep = ExpIC(t);
        let Em = ExpIC(-t);
        let matrix = [
            [C, O, O, pS],
            [O, C, mS, O],
            [O, pS, C, O],
            [mS, O, O, C]
        ];
        return RowMajorMatrix(matrix);
    }
    
    
    function ExpXZMatrix (t : Double) : RowMajorMatrix {
        
        let O = ZeroC();
        let C = Complex(Cos(t), 0.0);
        let IS = Complex(0.0, Sin(t));
        let mIS = Complex(0.0, -Sin(t));
        let pS = Complex(Sin(t), 0.0);
        let mS = Complex(-Sin(t), 0.0);
        let Ep = ExpIC(t);
        let Em = ExpIC(-t);
        let matrix = [
            [C, O, IS, O], [O, C, O, mIS],
            [IS, O, C, O],
            [O, mIS, O, C]
        ];
        return RowMajorMatrix(matrix);
    }
    
    
    function ExpYIMatrix (t : Double) : RowMajorMatrix {
        
        let O = ZeroC();
        let C = Complex(Cos(t), 0.0);
        let IS = Complex(0.0, Sin(t));
        let mIS = Complex(0.0, -Sin(t));
        let pS = Complex(Sin(t), 0.0);
        let mS = Complex(-Sin(t), 0.0);
        let Ep = ExpIC(t);
        let Em = ExpIC(-t);
        let matrix = [
            [C, O, pS, O],
            [O, C, O, pS],
            [mS, O, C, O],
            [O, mS, O, C]
        ];
        return RowMajorMatrix(matrix);
    }
    
    
    function ExpYXMatrix (t : Double) : RowMajorMatrix {
        
        let O = ZeroC();
        let C = Complex(Cos(t), 0.0);
        let IS = Complex(0.0, Sin(t));
        let mIS = Complex(0.0, -Sin(t));
        let pS = Complex(Sin(t), 0.0);
        let mS = Complex(-Sin(t), 0.0);
        let Ep = ExpIC(t);
        let Em = ExpIC(-t);
        let matrix = [
            [C, O, O, pS],
            [O, C, pS, O],
            [O, mS, C, O],
            [mS, O, O, C]
        ];
        return RowMajorMatrix(matrix);
    }
    
    
    function ExpYYMatrix (t : Double) : RowMajorMatrix {
        
        let O = ZeroC();
        let C = Complex(Cos(t), 0.0);
        let IS = Complex(0.0, Sin(t));
        let mIS = Complex(0.0, -Sin(t));
        let pS = Complex(Sin(t), 0.0);
        let mS = Complex(-Sin(t), 0.0);
        let Ep = ExpIC(t);
        let Em = ExpIC(-t);
        let matrix = [
            [C, O, O, mIS],
            [O, C, IS, O],
            [O, IS, C, O],
            [mIS, O, O, C]
        ];
        return RowMajorMatrix(matrix);
    }
    
    
    function ExpYZMatrix (t : Double) : RowMajorMatrix {
        
        let O = ZeroC();
        let C = Complex(Cos(t), 0.0);
        let IS = Complex(0.0, Sin(t));
        let mIS = Complex(0.0, -Sin(t));
        let pS = Complex(Sin(t), 0.0);
        let mS = Complex(-Sin(t), 0.0);
        let Ep = ExpIC(t);
        let Em = ExpIC(-t);
        let matrix = [
            [C, O, pS, O],
            [O, C, O, mS],
            [mS, O, C, O],
            [O, pS, O, C]
        ];
        return RowMajorMatrix(matrix);
    }
    
    
    function ExpZIMatrix (t : Double) : RowMajorMatrix {
        
        let O = ZeroC();
        let C = Complex(Cos(t), 0.0);
        let IS = Complex(0.0, Sin(t));
        let mIS = Complex(0.0, -Sin(t));
        let pS = Complex(Sin(t), 0.0);
        let mS = Complex(-Sin(t), 0.0);
        let Ep = ExpIC(t);
        let Em = ExpIC(-t);
        let matrix = [
            [Ep, O, O, O],
            [O, Ep, O, O],
            [O, O, Em, O],
            [O, O, O, Em]
        ];
        return RowMajorMatrix(matrix);
    }
    
    
    function ExpZXMatrix (t : Double) : RowMajorMatrix {
        
        let O = ZeroC();
        let C = Complex(Cos(t), 0.0);
        let IS = Complex(0.0, Sin(t));
        let mIS = Complex(0.0, -Sin(t));
        let pS = Complex(Sin(t), 0.0);
        let mS = Complex(-Sin(t), 0.0);
        let Ep = ExpIC(t);
        let Em = ExpIC(-t);
        let matrix = [
            [C, IS, O, O],
            [IS, C, O, O],
            [O, O, C, mIS],
            [O, O, mIS, C]
        ];
        return RowMajorMatrix(matrix);
    }
    
    
    function ExpZYMatrix (t : Double) : RowMajorMatrix {
        
        let O = ZeroC();
        let C = Complex(Cos(t), 0.0);
        let IS = Complex(0.0, Sin(t));
        let mIS = Complex(0.0, -Sin(t));
        let pS = Complex(Sin(t), 0.0);
        let mS = Complex(-Sin(t), 0.0);
        let Ep = ExpIC(t);
        let Em = ExpIC(-t);
        let matrix = [
            [C, pS, O, O],
            [mS, C, O, O],
            [O, O, C, mS],
            [O, O, pS, C]
        ];
        return RowMajorMatrix(matrix);
    }
    
    
    function ExpZZMatrix (t : Double) : RowMajorMatrix {
        
        let O = ZeroC();
        let C = Complex(Cos(t), 0.0);
        let IS = Complex(0.0, Sin(t));
        let mIS = Complex(0.0, -Sin(t));
        let pS = Complex(Sin(t), 0.0);
        let mS = Complex(-Sin(t), 0.0);
        let Ep = ExpIC(t);
        let Em = ExpIC(-t);
        let matrix = [
            [Ep, O, O, O],
            [O, Em, O, O],
            [O, O, Em, O],
            [O, O, O, Ep]
        ];
        return RowMajorMatrix(matrix);
    }
    
    
    function ExpIIIMatrix (t : Double) : RowMajorMatrix {
        
        let O = ZeroC();
        let C = Complex(Cos(t), 0.0);
        let IS = Complex(0.0, Sin(t));
        let mIS = Complex(0.0, -Sin(t));
        let pS = Complex(Sin(t), 0.0);
        let mS = Complex(-Sin(t), 0.0);
        let Ep = ExpIC(t);
        let Em = ExpIC(-t);
        let matrix = [
            [Ep, O, O, O, O, O, O, O],
            [O, Ep, O, O, O, O, O, O],
            [O, O, Ep, O, O, O, O, O],
            [O, O, O, Ep, O, O, O, O],
            [O, O, O, O, Ep, O, O, O],
            [O, O, O, O, O, Ep, O, O],
            [O, O, O, O, O, O, Ep, O],
            [O, O, O, O, O, O, O, Ep]
        ];
        return RowMajorMatrix(matrix);
    }
    
    
    function ExpIIXMatrix (t : Double) : RowMajorMatrix {
        
        let O = ZeroC();
        let C = Complex(Cos(t), 0.0);
        let IS = Complex(0.0, Sin(t));
        let mIS = Complex(0.0, -Sin(t));
        let pS = Complex(Sin(t), 0.0);
        let mS = Complex(-Sin(t), 0.0);
        let Ep = ExpIC(t);
        let Em = ExpIC(-t);
        let matrix = [
            [C, IS, O, O, O, O, O, O],
            [IS, C, O, O, O, O, O, O],
            [O, O, C, IS, O, O, O, O],
            [O, O, IS, C, O, O, O, O],
            [O, O, O, O, C, IS, O, O],
            [O, O, O, O, IS, C, O, O],
            [O, O, O, O, O, O, C, IS],
            [O, O, O, O, O, O, IS, C]
        ];
        return RowMajorMatrix(matrix);
    }
    
    
    function ExpIIYMatrix (t : Double) : RowMajorMatrix {
        
        let O = ZeroC();
        let C = Complex(Cos(t), 0.0);
        let IS = Complex(0.0, Sin(t));
        let mIS = Complex(0.0, -Sin(t));
        let pS = Complex(Sin(t), 0.0);
        let mS = Complex(-Sin(t), 0.0);
        let Ep = ExpIC(t);
        let Em = ExpIC(-t);
        let matrix = [
            [C, pS, O, O, O, O, O, O],
            [mS, C, O, O, O, O, O, O],
            [O, O, C, pS, O, O, O, O],
            [O, O, mS, C, O, O, O, O],
            [O, O, O, O, C, pS, O, O],
            [O, O, O, O, mS, C, O, O],
            [O, O, O, O, O, O, C, pS],
            [O, O, O, O, O, O, mS, C]
        ];
        return RowMajorMatrix(matrix);
    }
    
    
    function ExpIIZMatrix (t : Double) : RowMajorMatrix {
        
        let O = ZeroC();
        let C = Complex(Cos(t), 0.0);
        let IS = Complex(0.0, Sin(t));
        let mIS = Complex(0.0, -Sin(t));
        let pS = Complex(Sin(t), 0.0);
        let mS = Complex(-Sin(t), 0.0);
        let Ep = ExpIC(t);
        let Em = ExpIC(-t);
        let matrix = [
            [Ep, O, O, O, O, O, O, O],
            [O, Em, O, O, O, O, O, O],
            [O, O, Ep, O, O, O, O, O],
            [O, O, O, Em, O, O, O, O],
            [O, O, O, O, Ep, O, O, O],
            [O, O, O, O, O, Em, O, O],
            [O, O, O, O, O, O, Ep, O],
            [O, O, O, O, O, O, O, Em]
        ];
        return RowMajorMatrix(matrix);
    }
    
    
    function ExpIXIMatrix (t : Double) : RowMajorMatrix {
        
        let O = ZeroC();
        let C = Complex(Cos(t), 0.0);
        let IS = Complex(0.0, Sin(t));
        let mIS = Complex(0.0, -Sin(t));
        let pS = Complex(Sin(t), 0.0);
        let mS = Complex(-Sin(t), 0.0);
        let Ep = ExpIC(t);
        let Em = ExpIC(-t);
        let matrix = [
            [C, O, IS, O, O, O, O, O],
            [O, C, O, IS, O, O, O, O],
            [IS, O, C, O, O, O, O, O],
            [O, IS, O, C, O, O, O, O],
            [O, O, O, O, C, O, IS, O],
            [O, O, O, O, O, C, O, IS],
            [O, O, O, O, IS, O, C, O],
            [O, O, O, O, O, IS, O, C]
        ];
        return RowMajorMatrix(matrix);
    }
    
    
    function ExpIXXMatrix (t : Double) : RowMajorMatrix {
        
        let O = ZeroC();
        let C = Complex(Cos(t), 0.0);
        let IS = Complex(0.0, Sin(t));
        let mIS = Complex(0.0, -Sin(t));
        let pS = Complex(Sin(t), 0.0);
        let mS = Complex(-Sin(t), 0.0);
        let Ep = ExpIC(t);
        let Em = ExpIC(-t);
        let matrix = [
            [C, O, O, IS, O, O, O, O],
            [O, C, IS, O, O, O, O, O],
            [O, IS, C, O, O, O, O, O],
            [IS, O, O, C, O, O, O, O],
            [O, O, O, O, C, O, O, IS],
            [O, O, O, O, O, C, IS, O],
            [O, O, O, O, O, IS, C, O],
            [O, O, O, O, IS, O, O, C]
        ];
        return RowMajorMatrix(matrix);
    }
    
    
    function ExpIXYMatrix (t : Double) : RowMajorMatrix {
        
        let O = ZeroC();
        let C = Complex(Cos(t), 0.0);
        let IS = Complex(0.0, Sin(t));
        let mIS = Complex(0.0, -Sin(t));
        let pS = Complex(Sin(t), 0.0);
        let mS = Complex(-Sin(t), 0.0);
        let Ep = ExpIC(t);
        let Em = ExpIC(-t);
        let matrix = [
            [C, O, O, pS, O, O, O, O],
            [O, C, mS, O, O, O, O, O],
            [O, pS, C, O, O, O, O, O],
            [mS, O, O, C, O, O, O, O],
            [O, O, O, O, C, O, O, pS],
            [O, O, O, O, O, C, mS, O],
            [O, O, O, O, O, pS, C, O],
            [O, O, O, O, mS, O, O, C]
        ];
        return RowMajorMatrix(matrix);
    }
    
    
    function ExpIXZMatrix (t : Double) : RowMajorMatrix {
        
        let O = ZeroC();
        let C = Complex(Cos(t), 0.0);
        let IS = Complex(0.0, Sin(t));
        let mIS = Complex(0.0, -Sin(t));
        let pS = Complex(Sin(t), 0.0);
        let mS = Complex(-Sin(t), 0.0);
        let Ep = ExpIC(t);
        let Em = ExpIC(-t);
        let matrix = [
            [C, O, IS, O, O, O, O, O],
            [O, C, O, mIS, O, O, O, O],
            [IS, O, C, O, O, O, O, O],
            [O, mIS, O, C, O, O, O, O],
            [O, O, O, O, C, O, IS, O],
            [O, O, O, O, O, C, O, mIS],
            [O, O, O, O, IS, O, C, O],
            [O, O, O, O, O, mIS, O, C]
        ];
        return RowMajorMatrix(matrix);
    }
    
    
    function ExpIYIMatrix (t : Double) : RowMajorMatrix {
        
        let O = ZeroC();
        let C = Complex(Cos(t), 0.0);
        let IS = Complex(0.0, Sin(t));
        let mIS = Complex(0.0, -Sin(t));
        let pS = Complex(Sin(t), 0.0);
        let mS = Complex(-Sin(t), 0.0);
        let Ep = ExpIC(t);
        let Em = ExpIC(-t);
        let matrix = [
            [C, O, pS, O, O, O, O, O],
            [O, C, O, pS, O, O, O, O],
            [mS, O, C, O, O, O, O, O],
            [O, mS, O, C, O, O, O, O],
            [O, O, O, O, C, O, pS, O],
            [O, O, O, O, O, C, O, pS],
            [O, O, O, O, mS, O, C, O],
            [O, O, O, O, O, mS, O, C]
        ];
        return RowMajorMatrix(matrix);
    }
    
    
    function ExpIYXMatrix (t : Double) : RowMajorMatrix {
        
        let O = ZeroC();
        let C = Complex(Cos(t), 0.0);
        let IS = Complex(0.0, Sin(t));
        let mIS = Complex(0.0, -Sin(t));
        let pS = Complex(Sin(t), 0.0);
        let mS = Complex(-Sin(t), 0.0);
        let Ep = ExpIC(t);
        let Em = ExpIC(-t);
        let matrix = [
            [C, O, O, pS, O, O, O, O],
            [O, C, pS, O, O, O, O, O],
            [O, mS, C, O, O, O, O, O],
            [mS, O, O, C, O, O, O, O],
            [O, O, O, O, C, O, O, pS],
            [O, O, O, O, O, C, pS, O],
            [O, O, O, O, O, mS, C, O],
            [O, O, O, O, mS, O, O, C]
        ];
        return RowMajorMatrix(matrix);
    }
    
    
    function ExpIYYMatrix (t : Double) : RowMajorMatrix {
        
        let O = ZeroC();
        let C = Complex(Cos(t), 0.0);
        let IS = Complex(0.0, Sin(t));
        let mIS = Complex(0.0, -Sin(t));
        let pS = Complex(Sin(t), 0.0);
        let mS = Complex(-Sin(t), 0.0);
        let Ep = ExpIC(t);
        let Em = ExpIC(-t);
        let matrix = [
            [C, O, O, mIS, O, O, O, O],
            [O, C, IS, O, O, O, O, O],
            [O, IS, C, O, O, O, O, O],
            [mIS, O, O, C, O, O, O, O],
            [O, O, O, O, C, O, O, mIS],
            [O, O, O, O, O, C, IS, O],
            [O, O, O, O, O, IS, C, O],
            [O, O, O, O, mIS, O, O, C]
        ];
        return RowMajorMatrix(matrix);
    }
    
    
    function ExpIYZMatrix (t : Double) : RowMajorMatrix {
        
        let O = ZeroC();
        let C = Complex(Cos(t), 0.0);
        let IS = Complex(0.0, Sin(t));
        let mIS = Complex(0.0, -Sin(t));
        let pS = Complex(Sin(t), 0.0);
        let mS = Complex(-Sin(t), 0.0);
        let Ep = ExpIC(t);
        let Em = ExpIC(-t);
        let matrix = [
            [C, O, pS, O, O, O, O, O],
            [O, C, O, mS, O, O, O, O],
            [mS, O, C, O, O, O, O, O],
            [O, pS, O, C, O, O, O, O],
            [O, O, O, O, C, O, pS, O],
            [O, O, O, O, O, C, O, mS],
            [O, O, O, O, mS, O, C, O],
            [O, O, O, O, O, pS, O, C]
        ];
        return RowMajorMatrix(matrix);
    }
    
    
    function ExpIZIMatrix (t : Double) : RowMajorMatrix {
        
        let O = ZeroC();
        let C = Complex(Cos(t), 0.0);
        let IS = Complex(0.0, Sin(t));
        let mIS = Complex(0.0, -Sin(t));
        let pS = Complex(Sin(t), 0.0);
        let mS = Complex(-Sin(t), 0.0);
        let Ep = ExpIC(t);
        let Em = ExpIC(-t);
        let matrix = [
            [Ep, O, O, O, O, O, O, O],
            [O, Ep, O, O, O, O, O, O],
            [O, O, Em, O, O, O, O, O],
            [O, O, O, Em, O, O, O, O],
            [O, O, O, O, Ep, O, O, O],
            [O, O, O, O, O, Ep, O, O],
            [O, O, O, O, O, O, Em, O],
            [O, O, O, O, O, O, O, Em]
        ];
        return RowMajorMatrix(matrix);
    }
    
    
    function ExpIZXMatrix (t : Double) : RowMajorMatrix {
        
        let O = ZeroC();
        let C = Complex(Cos(t), 0.0);
        let IS = Complex(0.0, Sin(t));
        let mIS = Complex(0.0, -Sin(t));
        let pS = Complex(Sin(t), 0.0);
        let mS = Complex(-Sin(t), 0.0);
        let Ep = ExpIC(t);
        let Em = ExpIC(-t);
        let matrix = [
            [C, IS, O, O, O, O, O, O],
            [IS, C, O, O, O, O, O, O],
            [O, O, C, mIS, O, O, O, O],
            [O, O, mIS, C, O, O, O, O],
            [O, O, O, O, C, IS, O, O],
            [O, O, O, O, IS, C, O, O],
            [O, O, O, O, O, O, C, mIS],
            [O, O, O, O, O, O, mIS, C]
        ];
        return RowMajorMatrix(matrix);
    }
    
    
    function ExpIZYMatrix (t : Double) : RowMajorMatrix {
        
        let O = ZeroC();
        let C = Complex(Cos(t), 0.0);
        let IS = Complex(0.0, Sin(t));
        let mIS = Complex(0.0, -Sin(t));
        let pS = Complex(Sin(t), 0.0);
        let mS = Complex(-Sin(t), 0.0);
        let Ep = ExpIC(t);
        let Em = ExpIC(-t);
        let matrix = [
            [C, pS, O, O, O, O, O, O],
            [mS, C, O, O, O, O, O, O],
            [O, O, C, mS, O, O, O, O],
            [O, O, pS, C, O, O, O, O],
            [O, O, O, O, C, pS, O, O],
            [O, O, O, O, mS, C, O, O],
            [O, O, O, O, O, O, C, mS],
            [O, O, O, O, O, O, pS, C]
        ];
        return RowMajorMatrix(matrix);
    }
    
    
    function ExpIZZMatrix (t : Double) : RowMajorMatrix {
        
        let O = ZeroC();
        let C = Complex(Cos(t), 0.0);
        let IS = Complex(0.0, Sin(t));
        let mIS = Complex(0.0, -Sin(t));
        let pS = Complex(Sin(t), 0.0);
        let mS = Complex(-Sin(t), 0.0);
        let Ep = ExpIC(t);
        let Em = ExpIC(-t);
        let matrix = [
            [Ep, O, O, O, O, O, O, O],
            [O, Em, O, O, O, O, O, O],
            [O, O, Em, O, O, O, O, O],
            [O, O, O, Ep, O, O, O, O],
            [O, O, O, O, Ep, O, O, O],
            [O, O, O, O, O, Em, O, O],
            [O, O, O, O, O, O, Em, O],
            [O, O, O, O, O, O, O, Ep]
        ];
        return RowMajorMatrix(matrix);
    }
    
    
    function ExpXIIMatrix (t : Double) : RowMajorMatrix {
        
        let O = ZeroC();
        let C = Complex(Cos(t), 0.0);
        let IS = Complex(0.0, Sin(t));
        let mIS = Complex(0.0, -Sin(t));
        let pS = Complex(Sin(t), 0.0);
        let mS = Complex(-Sin(t), 0.0);
        let Ep = ExpIC(t);
        let Em = ExpIC(-t);
        let matrix = [
            [C, O, O, O, IS, O, O, O],
            [O, C, O, O, O, IS, O, O],
            [O, O, C, O, O, O, IS, O],
            [O, O, O, C, O, O, O, IS],
            [IS, O, O, O, C, O, O, O],
            [O, IS, O, O, O, C, O, O],
            [O, O, IS, O, O, O, C, O],
            [O, O, O, IS, O, O, O, C]
        ];
        return RowMajorMatrix(matrix);
    }
    
    
    function ExpXIXMatrix (t : Double) : RowMajorMatrix {
        
        let O = ZeroC();
        let C = Complex(Cos(t), 0.0);
        let IS = Complex(0.0, Sin(t));
        let mIS = Complex(0.0, -Sin(t));
        let pS = Complex(Sin(t), 0.0);
        let mS = Complex(-Sin(t), 0.0);
        let Ep = ExpIC(t);
        let Em = ExpIC(-t);
        let matrix = [
            [C, O, O, O, O, IS, O, O],
            [O, C, O, O, IS, O, O, O],
            [O, O, C, O, O, O, O, IS],
            [O, O, O, C, O, O, IS, O],
            [O, IS, O, O, C, O, O, O],
            [IS, O, O, O, O, C, O, O],
            [O, O, O, IS, O, O, C, O],
            [O, O, IS, O, O, O, O, C]
        ];
        return RowMajorMatrix(matrix);
    }
    
    
    function ExpXIYMatrix (t : Double) : RowMajorMatrix {
        
        let O = ZeroC();
        let C = Complex(Cos(t), 0.0);
        let IS = Complex(0.0, Sin(t));
        let mIS = Complex(0.0, -Sin(t));
        let pS = Complex(Sin(t), 0.0);
        let mS = Complex(-Sin(t), 0.0);
        let Ep = ExpIC(t);
        let Em = ExpIC(-t);
        let matrix = [
            [C, O, O, O, O, pS, O, O],
            [O, C, O, O, mS, O, O, O],
            [O, O, C, O, O, O, O, pS],
            [O, O, O, C, O, O, mS, O],
            [O, pS, O, O, C, O, O, O],
            [mS, O, O, O, O, C, O, O],
            [O, O, O, pS, O, O, C, O],
            [O, O, mS, O, O, O, O, C]
        ];
        return RowMajorMatrix(matrix);
    }
    
    
    function ExpXIZMatrix (t : Double) : RowMajorMatrix {
        
        let O = ZeroC();
        let C = Complex(Cos(t), 0.0);
        let IS = Complex(0.0, Sin(t));
        let mIS = Complex(0.0, -Sin(t));
        let pS = Complex(Sin(t), 0.0);
        let mS = Complex(-Sin(t), 0.0);
        let Ep = ExpIC(t);
        let Em = ExpIC(-t);
        let matrix = [
            [C, O, O, O, IS, O, O, O],
            [O, C, O, O, O, mIS, O, O],
            [O, O, C, O, O, O, IS, O],
            [O, O, O, C, O, O, O, mIS],
            [IS, O, O, O, C, O, O, O],
            [O, mIS, O, O, O, C, O, O],
            [O, O, IS, O, O, O, C, O],
            [O, O, O, mIS, O, O, O, C]
        ];
        return RowMajorMatrix(matrix);
    }
    
    
    function ExpXXIMatrix (t : Double) : RowMajorMatrix {
        
        let O = ZeroC();
        let C = Complex(Cos(t), 0.0);
        let IS = Complex(0.0, Sin(t));
        let mIS = Complex(0.0, -Sin(t));
        let pS = Complex(Sin(t), 0.0);
        let mS = Complex(-Sin(t), 0.0);
        let Ep = ExpIC(t);
        let Em = ExpIC(-t);
        let matrix = [
            [C, O, O, O, O, O, IS, O],
            [O, C, O, O, O, O, O, IS],
            [O, O, C, O, IS, O, O, O],
            [O, O, O, C, O, IS, O, O],
            [O, O, IS, O, C, O, O, O],
            [O, O, O, IS, O, C, O, O],
            [IS, O, O, O, O, O, C, O],
            [O, IS, O, O, O, O, O, C]
        ];
        return RowMajorMatrix(matrix);
    }
    
    
    function ExpXXXMatrix (t : Double) : RowMajorMatrix {
        
        let O = ZeroC();
        let C = Complex(Cos(t), 0.0);
        let IS = Complex(0.0, Sin(t));
        let mIS = Complex(0.0, -Sin(t));
        let pS = Complex(Sin(t), 0.0);
        let mS = Complex(-Sin(t), 0.0);
        let Ep = ExpIC(t);
        let Em = ExpIC(-t);
        let matrix = [
            [C, O, O, O, O, O, O, IS],
            [O, C, O, O, O, O, IS, O],
            [O, O, C, O, O, IS, O, O],
            [O, O, O, C, IS, O, O, O],
            [O, O, O, IS, C, O, O, O],
            [O, O, IS, O, O, C, O, O],
            [O, IS, O, O, O, O, C, O],
            [IS, O, O, O, O, O, O, C]
        ];
        return RowMajorMatrix(matrix);
    }
    
    
    function ExpXXYMatrix (t : Double) : RowMajorMatrix {
        
        let O = ZeroC();
        let C = Complex(Cos(t), 0.0);
        let IS = Complex(0.0, Sin(t));
        let mIS = Complex(0.0, -Sin(t));
        let pS = Complex(Sin(t), 0.0);
        let mS = Complex(-Sin(t), 0.0);
        let Ep = ExpIC(t);
        let Em = ExpIC(-t);
        let matrix = [
            [C, O, O, O, O, O, O, pS],
            [O, C, O, O, O, O, mS, O],
            [O, O, C, O, O, pS, O, O],
            [O, O, O, C, mS, O, O, O],
            [O, O, O, pS, C, O, O, O],
            [O, O, mS, O, O, C, O, O],
            [O, pS, O, O, O, O, C, O],
            [mS, O, O, O, O, O, O, C]
        ];
        return RowMajorMatrix(matrix);
    }
    
    
    function ExpXXZMatrix (t : Double) : RowMajorMatrix {
        
        let O = ZeroC();
        let C = Complex(Cos(t), 0.0);
        let IS = Complex(0.0, Sin(t));
        let mIS = Complex(0.0, -Sin(t));
        let pS = Complex(Sin(t), 0.0);
        let mS = Complex(-Sin(t), 0.0);
        let Ep = ExpIC(t);
        let Em = ExpIC(-t);
        let matrix = [
            [C, O, O, O, O, O, IS, O],
            [O, C, O, O, O, O, O, mIS],
            [O, O, C, O, IS, O, O, O],
            [O, O, O, C, O, mIS, O, O],
            [O, O, IS, O, C, O, O, O],
            [O, O, O, mIS, O, C, O, O],
            [IS, O, O, O, O, O, C, O],
            [O, mIS, O, O, O, O, O, C]
        ];
        return RowMajorMatrix(matrix);
    }
    
    
    function ExpXYIMatrix (t : Double) : RowMajorMatrix {
        
        let O = ZeroC();
        let C = Complex(Cos(t), 0.0);
        let IS = Complex(0.0, Sin(t));
        let mIS = Complex(0.0, -Sin(t));
        let pS = Complex(Sin(t), 0.0);
        let mS = Complex(-Sin(t), 0.0);
        let Ep = ExpIC(t);
        let Em = ExpIC(-t);
        let matrix = [
            [C, O, O, O, O, O, pS, O],
            [O, C, O, O, O, O, O, pS],
            [O, O, C, O, mS, O, O, O],
            [O, O, O, C, O, mS, O, O],
            [O, O, pS, O, C, O, O, O],
            [O, O, O, pS, O, C, O, O],
            [mS, O, O, O, O, O, C, O],
            [O, mS, O, O, O, O, O, C]
        ];
        return RowMajorMatrix(matrix);
    }
    
    
    function ExpXYXMatrix (t : Double) : RowMajorMatrix {
        
        let O = ZeroC();
        let C = Complex(Cos(t), 0.0);
        let IS = Complex(0.0, Sin(t));
        let mIS = Complex(0.0, -Sin(t));
        let pS = Complex(Sin(t), 0.0);
        let mS = Complex(-Sin(t), 0.0);
        let Ep = ExpIC(t);
        let Em = ExpIC(-t);
        let matrix = [
            [C, O, O, O, O, O, O, pS],
            [O, C, O, O, O, O, pS, O],
            [O, O, C, O, O, mS, O, O],
            [O, O, O, C, mS, O, O, O],
            [O, O, O, pS, C, O, O, O],
            [O, O, pS, O, O, C, O, O],
            [O, mS, O, O, O, O, C, O],
            [mS, O, O, O, O, O, O, C]
        ];
        return RowMajorMatrix(matrix);
    }
    
    
    function ExpXYYMatrix (t : Double) : RowMajorMatrix {
        
        let O = ZeroC();
        let C = Complex(Cos(t), 0.0);
        let IS = Complex(0.0, Sin(t));
        let mIS = Complex(0.0, -Sin(t));
        let pS = Complex(Sin(t), 0.0);
        let mS = Complex(-Sin(t), 0.0);
        let Ep = ExpIC(t);
        let Em = ExpIC(-t);
        let matrix = [
            [C, O, O, O, O, O, O, mIS],
            [O, C, O, O, O, O, IS, O],
            [O, O, C, O, O, IS, O, O],
            [O, O, O, C, mIS, O, O, O],
            [O, O, O, mIS, C, O, O, O],
            [O, O, IS, O, O, C, O, O],
            [O, IS, O, O, O, O, C, O],
            [mIS, O, O, O, O, O, O, C]
        ];
        return RowMajorMatrix(matrix);
    }
    
    
    function ExpXYZMatrix (t : Double) : RowMajorMatrix {
        
        let O = ZeroC();
        let C = Complex(Cos(t), 0.0);
        let IS = Complex(0.0, Sin(t));
        let mIS = Complex(0.0, -Sin(t));
        let pS = Complex(Sin(t), 0.0);
        let mS = Complex(-Sin(t), 0.0);
        let Ep = ExpIC(t);
        let Em = ExpIC(-t);
        let matrix = [
            [C, O, O, O, O, O, pS, O],
            [O, C, O, O, O, O, O, mS],
            [O, O, C, O, mS, O, O, O],
            [O, O, O, C, O, pS, O, O],
            [O, O, pS, O, C, O, O, O],
            [O, O, O, mS, O, C, O, O],
            [mS, O, O, O, O, O, C, O],
            [O, pS, O, O, O, O, O, C]
        ];
        return RowMajorMatrix(matrix);
    }
    
    
    function ExpXZIMatrix (t : Double) : RowMajorMatrix {
        
        let O = ZeroC();
        let C = Complex(Cos(t), 0.0);
        let IS = Complex(0.0, Sin(t));
        let mIS = Complex(0.0, -Sin(t));
        let pS = Complex(Sin(t), 0.0);
        let mS = Complex(-Sin(t), 0.0);
        let Ep = ExpIC(t);
        let Em = ExpIC(-t);
        let matrix = [
            [C, O, O, O, IS, O, O, O],
            [O, C, O, O, O, IS, O, O],
            [O, O, C, O, O, O, mIS, O],
            [O, O, O, C, O, O, O, mIS],
            [IS, O, O, O, C, O, O, O],
            [O, IS, O, O, O, C, O, O],
            [O, O, mIS, O, O, O, C, O],
            [O, O, O, mIS, O, O, O, C]
        ];
        return RowMajorMatrix(matrix);
    }
    
    
    function ExpXZXMatrix (t : Double) : RowMajorMatrix {
        
        let O = ZeroC();
        let C = Complex(Cos(t), 0.0);
        let IS = Complex(0.0, Sin(t));
        let mIS = Complex(0.0, -Sin(t));
        let pS = Complex(Sin(t), 0.0);
        let mS = Complex(-Sin(t), 0.0);
        let Ep = ExpIC(t);
        let Em = ExpIC(-t);
        let matrix = [
            [C, O, O, O, O, IS, O, O],
            [O, C, O, O, IS, O, O, O],
            [O, O, C, O, O, O, O, mIS],
            [O, O, O, C, O, O, mIS, O],
            [O, IS, O, O, C, O, O, O],
            [IS, O, O, O, O, C, O, O],
            [O, O, O, mIS, O, O, C, O],
            [O, O, mIS, O, O, O, O, C]
        ];
        return RowMajorMatrix(matrix);
    }
    
    
    function ExpXZYMatrix (t : Double) : RowMajorMatrix {
        
        let O = ZeroC();
        let C = Complex(Cos(t), 0.0);
        let IS = Complex(0.0, Sin(t));
        let mIS = Complex(0.0, -Sin(t));
        let pS = Complex(Sin(t), 0.0);
        let mS = Complex(-Sin(t), 0.0);
        let Ep = ExpIC(t);
        let Em = ExpIC(-t);
        let matrix = [
            [C, O, O, O, O, pS, O, O],
            [O, C, O, O, mS, O, O, O],
            [O, O, C, O, O, O, O, mS],
            [O, O, O, C, O, O, pS, O],
            [O, pS, O, O, C, O, O, O],
            [mS, O, O, O, O, C, O, O],
            [O, O, O, mS, O, O, C, O],
            [O, O, pS, O, O, O, O, C]
        ];
        return RowMajorMatrix(matrix);
    }
    
    
    function ExpXZZMatrix (t : Double) : RowMajorMatrix {
        
        let O = ZeroC();
        let C = Complex(Cos(t), 0.0);
        let IS = Complex(0.0, Sin(t));
        let mIS = Complex(0.0, -Sin(t));
        let pS = Complex(Sin(t), 0.0);
        let mS = Complex(-Sin(t), 0.0);
        let Ep = ExpIC(t);
        let Em = ExpIC(-t);
        let matrix = [
            [C, O, O, O, IS, O, O, O],
            [O, C, O, O, O, mIS, O, O],
            [O, O, C, O, O, O, mIS, O],
            [O, O, O, C, O, O, O, IS],
            [IS, O, O, O, C, O, O, O],
            [O, mIS, O, O, O, C, O, O],
            [O, O, mIS, O, O, O, C, O],
            [O, O, O, IS, O, O, O, C]
        ];
        return RowMajorMatrix(matrix);
    }
    
    
    function ExpYIIMatrix (t : Double) : RowMajorMatrix {
        
        let O = ZeroC();
        let C = Complex(Cos(t), 0.0);
        let IS = Complex(0.0, Sin(t));
        let mIS = Complex(0.0, -Sin(t));
        let pS = Complex(Sin(t), 0.0);
        let mS = Complex(-Sin(t), 0.0);
        let Ep = ExpIC(t);
        let Em = ExpIC(-t);
        let matrix = [
            [C, O, O, O, pS, O, O, O],
            [O, C, O, O, O, pS, O, O],
            [O, O, C, O, O, O, pS, O],
            [O, O, O, C, O, O, O, pS],
            [mS, O, O, O, C, O, O, O],
            [O, mS, O, O, O, C, O, O],
            [O, O, mS, O, O, O, C, O],
            [O, O, O, mS, O, O, O, C]
        ];
        return RowMajorMatrix(matrix);
    }
    
    
    function ExpYIXMatrix (t : Double) : RowMajorMatrix {
        
        let O = ZeroC();
        let C = Complex(Cos(t), 0.0);
        let IS = Complex(0.0, Sin(t));
        let mIS = Complex(0.0, -Sin(t));
        let pS = Complex(Sin(t), 0.0);
        let mS = Complex(-Sin(t), 0.0);
        let Ep = ExpIC(t);
        let Em = ExpIC(-t);
        let matrix = [
            [C, O, O, O, O, pS, O, O],
            [O, C, O, O, pS, O, O, O],
            [O, O, C, O, O, O, O, pS],
            [O, O, O, C, O, O, pS, O],
            [O, mS, O, O, C, O, O, O],
            [mS, O, O, O, O, C, O, O],
            [O, O, O, mS, O, O, C, O],
            [O, O, mS, O, O, O, O, C]
        ];
        return RowMajorMatrix(matrix);
    }
    
    
    function ExpYIYMatrix (t : Double) : RowMajorMatrix {
        
        let O = ZeroC();
        let C = Complex(Cos(t), 0.0);
        let IS = Complex(0.0, Sin(t));
        let mIS = Complex(0.0, -Sin(t));
        let pS = Complex(Sin(t), 0.0);
        let mS = Complex(-Sin(t), 0.0);
        let Ep = ExpIC(t);
        let Em = ExpIC(-t);
        let matrix = [
            [C, O, O, O, O, mIS, O, O],
            [O, C, O, O, IS, O, O, O],
            [O, O, C, O, O, O, O, mIS],
            [O, O, O, C, O, O, IS, O],
            [O, IS, O, O, C, O, O, O],
            [mIS, O, O, O, O, C, O, O],
            [O, O, O, IS, O, O, C, O],
            [O, O, mIS, O, O, O, O, C]
        ];
        return RowMajorMatrix(matrix);
    }
    
    
    function ExpYIZMatrix (t : Double) : RowMajorMatrix {
        
        let O = ZeroC();
        let C = Complex(Cos(t), 0.0);
        let IS = Complex(0.0, Sin(t));
        let mIS = Complex(0.0, -Sin(t));
        let pS = Complex(Sin(t), 0.0);
        let mS = Complex(-Sin(t), 0.0);
        let Ep = ExpIC(t);
        let Em = ExpIC(-t);
        let matrix = [
            [C, O, O, O, pS, O, O, O],
            [O, C, O, O, O, mS, O, O],
            [O, O, C, O, O, O, pS, O],
            [O, O, O, C, O, O, O, mS],
            [mS, O, O, O, C, O, O, O],
            [O, pS, O, O, O, C, O, O],
            [O, O, mS, O, O, O, C, O],
            [O, O, O, pS, O, O, O, C]
        ];
        return RowMajorMatrix(matrix);
    }
    
    
    function ExpYXIMatrix (t : Double) : RowMajorMatrix {
        
        let O = ZeroC();
        let C = Complex(Cos(t), 0.0);
        let IS = Complex(0.0, Sin(t));
        let mIS = Complex(0.0, -Sin(t));
        let pS = Complex(Sin(t), 0.0);
        let mS = Complex(-Sin(t), 0.0);
        let Ep = ExpIC(t);
        let Em = ExpIC(-t);
        let matrix = [
            [C, O, O, O, O, O, pS, O],
            [O, C, O, O, O, O, O, pS],
            [O, O, C, O, pS, O, O, O],
            [O, O, O, C, O, pS, O, O],
            [O, O, mS, O, C, O, O, O],
            [O, O, O, mS, O, C, O, O],
            [mS, O, O, O, O, O, C, O],
            [O, mS, O, O, O, O, O, C]
        ];
        return RowMajorMatrix(matrix);
    }
    
    
    function ExpYXXMatrix (t : Double) : RowMajorMatrix {
        
        let O = ZeroC();
        let C = Complex(Cos(t), 0.0);
        let IS = Complex(0.0, Sin(t));
        let mIS = Complex(0.0, -Sin(t));
        let pS = Complex(Sin(t), 0.0);
        let mS = Complex(-Sin(t), 0.0);
        let Ep = ExpIC(t);
        let Em = ExpIC(-t);
        let matrix = [
            [C, O, O, O, O, O, O, pS],
            [O, C, O, O, O, O, pS, O],
            [O, O, C, O, O, pS, O, O],
            [O, O, O, C, pS, O, O, O],
            [O, O, O, mS, C, O, O, O],
            [O, O, mS, O, O, C, O, O],
            [O, mS, O, O, O, O, C, O],
            [mS, O, O, O, O, O, O, C]
        ];
        return RowMajorMatrix(matrix);
    }
    
    
    function ExpYXYMatrix (t : Double) : RowMajorMatrix {
        
        let O = ZeroC();
        let C = Complex(Cos(t), 0.0);
        let IS = Complex(0.0, Sin(t));
        let mIS = Complex(0.0, -Sin(t));
        let pS = Complex(Sin(t), 0.0);
        let mS = Complex(-Sin(t), 0.0);
        let Ep = ExpIC(t);
        let Em = ExpIC(-t);
        let matrix = [
            [C, O, O, O, O, O, O, mIS],
            [O, C, O, O, O, O, IS, O],
            [O, O, C, O, O, mIS, O, O],
            [O, O, O, C, IS, O, O, O],
            [O, O, O, IS, C, O, O, O],
            [O, O, mIS, O, O, C, O, O],
            [O, IS, O, O, O, O, C, O],
            [mIS, O, O, O, O, O, O, C]
        ];
        return RowMajorMatrix(matrix);
    }
    
    
    function ExpYXZMatrix (t : Double) : RowMajorMatrix {
        
        let O = ZeroC();
        let C = Complex(Cos(t), 0.0);
        let IS = Complex(0.0, Sin(t));
        let mIS = Complex(0.0, -Sin(t));
        let pS = Complex(Sin(t), 0.0);
        let mS = Complex(-Sin(t), 0.0);
        let Ep = ExpIC(t);
        let Em = ExpIC(-t);
        let matrix = [
            [C, O, O, O, O, O, pS, O],
            [O, C, O, O, O, O, O, mS],
            [O, O, C, O, pS, O, O, O],
            [O, O, O, C, O, mS, O, O],
            [O, O, mS, O, C, O, O, O],
            [O, O, O, pS, O, C, O, O],
            [mS, O, O, O, O, O, C, O],
            [O, pS, O, O, O, O, O, C]
        ];
        return RowMajorMatrix(matrix);
    }
    
    
    function ExpYYIMatrix (t : Double) : RowMajorMatrix {
        
        let O = ZeroC();
        let C = Complex(Cos(t), 0.0);
        let IS = Complex(0.0, Sin(t));
        let mIS = Complex(0.0, -Sin(t));
        let pS = Complex(Sin(t), 0.0);
        let mS = Complex(-Sin(t), 0.0);
        let Ep = ExpIC(t);
        let Em = ExpIC(-t);
        let matrix = [
            [C, O, O, O, O, O, mIS, O],
            [O, C, O, O, O, O, O, mIS],
            [O, O, C, O, IS, O, O, O],
            [O, O, O, C, O, IS, O, O],
            [O, O, IS, O, C, O, O, O],
            [O, O, O, IS, O, C, O, O],
            [mIS, O, O, O, O, O, C, O],
            [O, mIS, O, O, O, O, O, C]
        ];
        return RowMajorMatrix(matrix);
    }
    
    
    function ExpYYXMatrix (t : Double) : RowMajorMatrix {
        
        let O = ZeroC();
        let C = Complex(Cos(t), 0.0);
        let IS = Complex(0.0, Sin(t));
        let mIS = Complex(0.0, -Sin(t));
        let pS = Complex(Sin(t), 0.0);
        let mS = Complex(-Sin(t), 0.0);
        let Ep = ExpIC(t);
        let Em = ExpIC(-t);
        let matrix = [
            [C, O, O, O, O, O, O, mIS],
            [O, C, O, O, O, O, mIS, O],
            [O, O, C, O, O, IS, O, O],
            [O, O, O, C, IS, O, O, O],
            [O, O, O, IS, C, O, O, O],
            [O, O, IS, O, O, C, O, O],
            [O, mIS, O, O, O, O, C, O],
            [mIS, O, O, O, O, O, O, C]
        ];
        return RowMajorMatrix(matrix);
    }
    
    
    function ExpYYYMatrix (t : Double) : RowMajorMatrix {
        
        let O = ZeroC();
        let C = Complex(Cos(t), 0.0);
        let IS = Complex(0.0, Sin(t));
        let mIS = Complex(0.0, -Sin(t));
        let pS = Complex(Sin(t), 0.0);
        let mS = Complex(-Sin(t), 0.0);
        let Ep = ExpIC(t);
        let Em = ExpIC(-t);
        let matrix = [
            [C, O, O, O, O, O, O, mS],
            [O, C, O, O, O, O, pS, O],
            [O, O, C, O, O, pS, O, O],
            [O, O, O, C, mS, O, O, O],
            [O, O, O, pS, C, O, O, O],
            [O, O, mS, O, O, C, O, O],
            [O, mS, O, O, O, O, C, O],
            [pS, O, O, O, O, O, O, C]
        ];
        return RowMajorMatrix(matrix);
    }
    
    
    function ExpYYZMatrix (t : Double) : RowMajorMatrix {
        
        let O = ZeroC();
        let C = Complex(Cos(t), 0.0);
        let IS = Complex(0.0, Sin(t));
        let mIS = Complex(0.0, -Sin(t));
        let pS = Complex(Sin(t), 0.0);
        let mS = Complex(-Sin(t), 0.0);
        let Ep = ExpIC(t);
        let Em = ExpIC(-t);
        let matrix = [
            [C, O, O, O, O, O, mIS, O],
            [O, C, O, O, O, O, O, IS],
            [O, O, C, O, IS, O, O, O],
            [O, O, O, C, O, mIS, O, O],
            [O, O, IS, O, C, O, O, O],
            [O, O, O, mIS, O, C, O, O],
            [mIS, O, O, O, O, O, C, O],
            [O, IS, O, O, O, O, O, C]
        ];
        return RowMajorMatrix(matrix);
    }
    
    
    function ExpYZIMatrix (t : Double) : RowMajorMatrix {
        
        let O = ZeroC();
        let C = Complex(Cos(t), 0.0);
        let IS = Complex(0.0, Sin(t));
        let mIS = Complex(0.0, -Sin(t));
        let pS = Complex(Sin(t), 0.0);
        let mS = Complex(-Sin(t), 0.0);
        let Ep = ExpIC(t);
        let Em = ExpIC(-t);
        let matrix = [
            [C, O, O, O, pS, O, O, O],
            [O, C, O, O, O, pS, O, O],
            [O, O, C, O, O, O, mS, O],
            [O, O, O, C, O, O, O, mS],
            [mS, O, O, O, C, O, O, O],
            [O, mS, O, O, O, C, O, O],
            [O, O, pS, O, O, O, C, O],
            [O, O, O, pS, O, O, O, C]
        ];
        return RowMajorMatrix(matrix);
    }
    
    
    function ExpYZXMatrix (t : Double) : RowMajorMatrix {
        
        let O = ZeroC();
        let C = Complex(Cos(t), 0.0);
        let IS = Complex(0.0, Sin(t));
        let mIS = Complex(0.0, -Sin(t));
        let pS = Complex(Sin(t), 0.0);
        let mS = Complex(-Sin(t), 0.0);
        let Ep = ExpIC(t);
        let Em = ExpIC(-t);
        let matrix = [
            [C, O, O, O, O, pS, O, O],
            [O, C, O, O, pS, O, O, O],
            [O, O, C, O, O, O, O, mS],
            [O, O, O, C, O, O, mS, O],
            [O, mS, O, O, C, O, O, O],
            [mS, O, O, O, O, C, O, O],
            [O, O, O, pS, O, O, C, O],
            [O, O, pS, O, O, O, O, C]
        ];
        return RowMajorMatrix(matrix);
    }
    
    
    function ExpYZYMatrix (t : Double) : RowMajorMatrix {
        
        let O = ZeroC();
        let C = Complex(Cos(t), 0.0);
        let IS = Complex(0.0, Sin(t));
        let mIS = Complex(0.0, -Sin(t));
        let pS = Complex(Sin(t), 0.0);
        let mS = Complex(-Sin(t), 0.0);
        let Ep = ExpIC(t);
        let Em = ExpIC(-t);
        let matrix = [
            [C, O, O, O, O, mIS, O, O],
            [O, C, O, O, IS, O, O, O],
            [O, O, C, O, O, O, O, IS],
            [O, O, O, C, O, O, mIS, O],
            [O, IS, O, O, C, O, O, O],
            [mIS, O, O, O, O, C, O, O],
            [O, O, O, mIS, O, O, C, O],
            [O, O, IS, O, O, O, O, C]
        ];
        return RowMajorMatrix(matrix);
    }
    
    
    function ExpYZZMatrix (t : Double) : RowMajorMatrix {
        
        let O = ZeroC();
        let C = Complex(Cos(t), 0.0);
        let IS = Complex(0.0, Sin(t));
        let mIS = Complex(0.0, -Sin(t));
        let pS = Complex(Sin(t), 0.0);
        let mS = Complex(-Sin(t), 0.0);
        let Ep = ExpIC(t);
        let Em = ExpIC(-t);
        let matrix = [
            [C, O, O, O, pS, O, O, O],
            [O, C, O, O, O, mS, O, O],
            [O, O, C, O, O, O, mS, O],
            [O, O, O, C, O, O, O, pS],
            [mS, O, O, O, C, O, O, O],
            [O, pS, O, O, O, C, O, O],
            [O, O, pS, O, O, O, C, O],
            [O, O, O, mS, O, O, O, C]
        ];
        return RowMajorMatrix(matrix);
    }
    
    
    function ExpZIIMatrix (t : Double) : RowMajorMatrix {
        
        let O = ZeroC();
        let C = Complex(Cos(t), 0.0);
        let IS = Complex(0.0, Sin(t));
        let mIS = Complex(0.0, -Sin(t));
        let pS = Complex(Sin(t), 0.0);
        let mS = Complex(-Sin(t), 0.0);
        let Ep = ExpIC(t);
        let Em = ExpIC(-t);
        let matrix = [
            [Ep, O, O, O, O, O, O, O],
            [O, Ep, O, O, O, O, O, O],
            [O, O, Ep, O, O, O, O, O],
            [O, O, O, Ep, O, O, O, O],
            [O, O, O, O, Em, O, O, O],
            [O, O, O, O, O, Em, O, O],
            [O, O, O, O, O, O, Em, O],
            [O, O, O, O, O, O, O, Em]
        ];
        return RowMajorMatrix(matrix);
    }
    
    
    function ExpZIXMatrix (t : Double) : RowMajorMatrix {
        
        let O = ZeroC();
        let C = Complex(Cos(t), 0.0);
        let IS = Complex(0.0, Sin(t));
        let mIS = Complex(0.0, -Sin(t));
        let pS = Complex(Sin(t), 0.0);
        let mS = Complex(-Sin(t), 0.0);
        let Ep = ExpIC(t);
        let Em = ExpIC(-t);
        let matrix = [
            [C, IS, O, O, O, O, O, O],
            [IS, C, O, O, O, O, O, O],
            [O, O, C, IS, O, O, O, O],
            [O, O, IS, C, O, O, O, O],
            [O, O, O, O, C, mIS, O, O],
            [O, O, O, O, mIS, C, O, O],
            [O, O, O, O, O, O, C, mIS],
            [O, O, O, O, O, O, mIS, C]
        ];
        return RowMajorMatrix(matrix);
    }
    
    
    function ExpZIYMatrix (t : Double) : RowMajorMatrix {
        
        let O = ZeroC();
        let C = Complex(Cos(t), 0.0);
        let IS = Complex(0.0, Sin(t));
        let mIS = Complex(0.0, -Sin(t));
        let pS = Complex(Sin(t), 0.0);
        let mS = Complex(-Sin(t), 0.0);
        let Ep = ExpIC(t);
        let Em = ExpIC(-t);
        let matrix = [
            [C, pS, O, O, O, O, O, O],
            [mS, C, O, O, O, O, O, O],
            [O, O, C, pS, O, O, O, O],
            [O, O, mS, C, O, O, O, O],
            [O, O, O, O, C, mS, O, O],
            [O, O, O, O, pS, C, O, O],
            [O, O, O, O, O, O, C, mS],
            [O, O, O, O, O, O, pS, C]
        ];
        return RowMajorMatrix(matrix);
    }
    
    
    function ExpZIZMatrix (t : Double) : RowMajorMatrix {
        
        let O = ZeroC();
        let C = Complex(Cos(t), 0.0);
        let IS = Complex(0.0, Sin(t));
        let mIS = Complex(0.0, -Sin(t));
        let pS = Complex(Sin(t), 0.0);
        let mS = Complex(-Sin(t), 0.0);
        let Ep = ExpIC(t);
        let Em = ExpIC(-t);
        let matrix = [
            [Ep, O, O, O, O, O, O, O],
            [O, Em, O, O, O, O, O, O],
            [O, O, Ep, O, O, O, O, O],
            [O, O, O, Em, O, O, O, O],
            [O, O, O, O, Em, O, O, O],
            [O, O, O, O, O, Ep, O, O],
            [O, O, O, O, O, O, Em, O],
            [O, O, O, O, O, O, O, Ep]
        ];
        return RowMajorMatrix(matrix);
    }
    
    
    function ExpZXIMatrix (t : Double) : RowMajorMatrix {
        
        let O = ZeroC();
        let C = Complex(Cos(t), 0.0);
        let IS = Complex(0.0, Sin(t));
        let mIS = Complex(0.0, -Sin(t));
        let pS = Complex(Sin(t), 0.0);
        let mS = Complex(-Sin(t), 0.0);
        let Ep = ExpIC(t);
        let Em = ExpIC(-t);
        let matrix = [
            [C, O, IS, O, O, O, O, O],
            [O, C, O, IS, O, O, O, O],
            [IS, O, C, O, O, O, O, O],
            [O, IS, O, C, O, O, O, O],
            [O, O, O, O, C, O, mIS, O],
            [O, O, O, O, O, C, O, mIS],
            [O, O, O, O, mIS, O, C, O],
            [O, O, O, O, O, mIS, O, C]
        ];
        return RowMajorMatrix(matrix);
    }
    
    
    function ExpZXXMatrix (t : Double) : RowMajorMatrix {
        
        let O = ZeroC();
        let C = Complex(Cos(t), 0.0);
        let IS = Complex(0.0, Sin(t));
        let mIS = Complex(0.0, -Sin(t));
        let pS = Complex(Sin(t), 0.0);
        let mS = Complex(-Sin(t), 0.0);
        let Ep = ExpIC(t);
        let Em = ExpIC(-t);
        let matrix = [
            [C, O, O, IS, O, O, O, O],
            [O, C, IS, O, O, O, O, O],
            [O, IS, C, O, O, O, O, O],
            [IS, O, O, C, O, O, O, O],
            [O, O, O, O, C, O, O, mIS],
            [O, O, O, O, O, C, mIS, O],
            [O, O, O, O, O, mIS, C, O],
            [O, O, O, O, mIS, O, O, C]
        ];
        return RowMajorMatrix(matrix);
    }
    
    
    function ExpZXYMatrix (t : Double) : RowMajorMatrix {
        
        let O = ZeroC();
        let C = Complex(Cos(t), 0.0);
        let IS = Complex(0.0, Sin(t));
        let mIS = Complex(0.0, -Sin(t));
        let pS = Complex(Sin(t), 0.0);
        let mS = Complex(-Sin(t), 0.0);
        let Ep = ExpIC(t);
        let Em = ExpIC(-t);
        let matrix = [
            [C, O, O, pS, O, O, O, O],
            [O, C, mS, O, O, O, O, O],
            [O, pS, C, O, O, O, O, O],
            [mS, O, O, C, O, O, O, O],
            [O, O, O, O, C, O, O, mS],
            [O, O, O, O, O, C, pS, O],
            [O, O, O, O, O, mS, C, O],
            [O, O, O, O, pS, O, O, C]
        ];
        return RowMajorMatrix(matrix);
    }
    
    
    function ExpZXZMatrix (t : Double) : RowMajorMatrix {
        
        let O = ZeroC();
        let C = Complex(Cos(t), 0.0);
        let IS = Complex(0.0, Sin(t));
        let mIS = Complex(0.0, -Sin(t));
        let pS = Complex(Sin(t), 0.0);
        let mS = Complex(-Sin(t), 0.0);
        let Ep = ExpIC(t);
        let Em = ExpIC(-t);
        let matrix = [
            [C, O, IS, O, O, O, O, O],
            [O, C, O, mIS, O, O, O, O],
            [IS, O, C, O, O, O, O, O],
            [O, mIS, O, C, O, O, O, O],
            [O, O, O, O, C, O, mIS, O],
            [O, O, O, O, O, C, O, IS],
            [O, O, O, O, mIS, O, C, O],
            [O, O, O, O, O, IS, O, C]
        ];
        return RowMajorMatrix(matrix);
    }
    
    
    function ExpZYIMatrix (t : Double) : RowMajorMatrix {
        
        let O = ZeroC();
        let C = Complex(Cos(t), 0.0);
        let IS = Complex(0.0, Sin(t));
        let mIS = Complex(0.0, -Sin(t));
        let pS = Complex(Sin(t), 0.0);
        let mS = Complex(-Sin(t), 0.0);
        let Ep = ExpIC(t);
        let Em = ExpIC(-t);
        let matrix = [
            [C, O, pS, O, O, O, O, O],
            [O, C, O, pS, O, O, O, O],
            [mS, O, C, O, O, O, O, O],
            [O, mS, O, C, O, O, O, O],
            [O, O, O, O, C, O, mS, O],
            [O, O, O, O, O, C, O, mS],
            [O, O, O, O, pS, O, C, O],
            [O, O, O, O, O, pS, O, C]
        ];
        return RowMajorMatrix(matrix);
    }
    
    
    function ExpZYXMatrix (t : Double) : RowMajorMatrix {
        
        let O = ZeroC();
        let C = Complex(Cos(t), 0.0);
        let IS = Complex(0.0, Sin(t));
        let mIS = Complex(0.0, -Sin(t));
        let pS = Complex(Sin(t), 0.0);
        let mS = Complex(-Sin(t), 0.0);
        let Ep = ExpIC(t);
        let Em = ExpIC(-t);
        let matrix = [
            [C, O, O, pS, O, O, O, O],
            [O, C, pS, O, O, O, O, O],
            [O, mS, C, O, O, O, O, O],
            [mS, O, O, C, O, O, O, O],
            [O, O, O, O, C, O, O, mS],
            [O, O, O, O, O, C, mS, O],
            [O, O, O, O, O, pS, C, O],
            [O, O, O, O, pS, O, O, C]
        ];
        return RowMajorMatrix(matrix);
    }
    
    
    function ExpZYYMatrix (t : Double) : RowMajorMatrix {
        
        let O = ZeroC();
        let C = Complex(Cos(t), 0.0);
        let IS = Complex(0.0, Sin(t));
        let mIS = Complex(0.0, -Sin(t));
        let pS = Complex(Sin(t), 0.0);
        let mS = Complex(-Sin(t), 0.0);
        let Ep = ExpIC(t);
        let Em = ExpIC(-t);
        let matrix = [
            [C, O, O, mIS, O, O, O, O],
            [O, C, IS, O, O, O, O, O],
            [O, IS, C, O, O, O, O, O],
            [mIS, O, O, C, O, O, O, O],
            [O, O, O, O, C, O, O, IS],
            [O, O, O, O, O, C, mIS, O],
            [O, O, O, O, O, mIS, C, O],
            [O, O, O, O, IS, O, O, C]
        ];
        return RowMajorMatrix(matrix);
    }
    
    
    function ExpZYZMatrix (t : Double) : RowMajorMatrix {
        
        let O = ZeroC();
        let C = Complex(Cos(t), 0.0);
        let IS = Complex(0.0, Sin(t));
        let mIS = Complex(0.0, -Sin(t));
        let pS = Complex(Sin(t), 0.0);
        let mS = Complex(-Sin(t), 0.0);
        let Ep = ExpIC(t);
        let Em = ExpIC(-t);
        let matrix = [
            [C, O, pS, O, O, O, O, O],
            [O, C, O, mS, O, O, O, O],
            [mS, O, C, O, O, O, O, O],
            [O, pS, O, C, O, O, O, O],
            [O, O, O, O, C, O, mS, O],
            [O, O, O, O, O, C, O, pS],
            [O, O, O, O, pS, O, C, O],
            [O, O, O, O, O, mS, O, C]
        ];
        return RowMajorMatrix(matrix);
    }
    
    
    function ExpZZIMatrix (t : Double) : RowMajorMatrix {
        
        let O = ZeroC();
        let C = Complex(Cos(t), 0.0);
        let IS = Complex(0.0, Sin(t));
        let mIS = Complex(0.0, -Sin(t));
        let pS = Complex(Sin(t), 0.0);
        let mS = Complex(-Sin(t), 0.0);
        let Ep = ExpIC(t);
        let Em = ExpIC(-t);
        let matrix = [
            [Ep, O, O, O, O, O, O, O],
            [O, Ep, O, O, O, O, O, O],
            [O, O, Em, O, O, O, O, O],
            [O, O, O, Em, O, O, O, O],
            [O, O, O, O, Em, O, O, O],
            [O, O, O, O, O, Em, O, O],
            [O, O, O, O, O, O, Ep, O],
            [O, O, O, O, O, O, O, Ep]
        ];
        return RowMajorMatrix(matrix);
    }
    
    
    function ExpZZXMatrix (t : Double) : RowMajorMatrix {
        
        let O = ZeroC();
        let C = Complex(Cos(t), 0.0);
        let IS = Complex(0.0, Sin(t));
        let mIS = Complex(0.0, -Sin(t));
        let pS = Complex(Sin(t), 0.0);
        let mS = Complex(-Sin(t), 0.0);
        let Ep = ExpIC(t);
        let Em = ExpIC(-t);
        let matrix = [
            [C, IS, O, O, O, O, O, O],
            [IS, C, O, O, O, O, O, O],
            [O, O, C, mIS, O, O, O, O],
            [O, O, mIS, C, O, O, O, O],
            [O, O, O, O, C, mIS, O, O],
            [O, O, O, O, mIS, C, O, O],
            [O, O, O, O, O, O, C, IS],
            [O, O, O, O, O, O, IS, C]
        ];
        return RowMajorMatrix(matrix);
    }
    
    
    function ExpZZYMatrix (t : Double) : RowMajorMatrix {
        
        let O = ZeroC();
        let C = Complex(Cos(t), 0.0);
        let IS = Complex(0.0, Sin(t));
        let mIS = Complex(0.0, -Sin(t));
        let pS = Complex(Sin(t), 0.0);
        let mS = Complex(-Sin(t), 0.0);
        let Ep = ExpIC(t);
        let Em = ExpIC(-t);
        let matrix = [
            [C, pS, O, O, O, O, O, O],
            [mS, C, O, O, O, O, O, O],
            [O, O, C, mS, O, O, O, O],
            [O, O, pS, C, O, O, O, O],
            [O, O, O, O, C, mS, O, O],
            [O, O, O, O, pS, C, O, O],
            [O, O, O, O, O, O, C, pS],
            [O, O, O, O, O, O, mS, C]
        ];
        return RowMajorMatrix(matrix);
    }
    
    
    function ExpZZZMatrix (t : Double) : RowMajorMatrix {
        
        let O = ZeroC();
        let C = Complex(Cos(t), 0.0);
        let IS = Complex(0.0, Sin(t));
        let mIS = Complex(0.0, -Sin(t));
        let pS = Complex(Sin(t), 0.0);
        let mS = Complex(-Sin(t), 0.0);
        let Ep = ExpIC(t);
        let Em = ExpIC(-t);
        let matrix = [
            [Ep, O, O, O, O, O, O, O],
            [O, Em, O, O, O, O, O, O],
            [O, O, Em, O, O, O, O, O],
            [O, O, O, Ep, O, O, O, O],
            [O, O, O, O, Em, O, O, O],
            [O, O, O, O, O, Ep, O, O],
            [O, O, O, O, O, O, Ep, O],
            [O, O, O, O, O, O, O, Em]
        ];
        return RowMajorMatrix(matrix);
    }
    
    
    function ExpMultiPauliMatrix (paulies : Pauli[], t : Double) : RowMajorMatrix {
        let len = Length(paulies);
        
        if (len > 3) {
            fail $"Pauli arrays of length more than 3 are not supported";
        }
        
        let index = PauliArrayAsInt(paulies);
        let functionLookup = [
            [ExpIMatrix, ExpXMatrix, ExpZMatrix, ExpYMatrix],
            [ExpIIMatrix, ExpIXMatrix, ExpIZMatrix, ExpIYMatrix, ExpXIMatrix, ExpXXMatrix, ExpXZMatrix, ExpXYMatrix, ExpZIMatrix, ExpZXMatrix, ExpZZMatrix, ExpZYMatrix, ExpYIMatrix, ExpYXMatrix, ExpYZMatrix, ExpYYMatrix],
            [ExpIIIMatrix, ExpIIXMatrix, ExpIIZMatrix, ExpIIYMatrix, ExpIXIMatrix, ExpIXXMatrix, ExpIXZMatrix, ExpIXYMatrix, ExpIZIMatrix, ExpIZXMatrix, ExpIZZMatrix, ExpIZYMatrix, ExpIYIMatrix, ExpIYXMatrix, ExpIYZMatrix, ExpIYYMatrix, ExpXIIMatrix, ExpXIXMatrix, ExpXIZMatrix, ExpXIYMatrix, ExpXXIMatrix, ExpXXXMatrix, ExpXXZMatrix, ExpXXYMatrix, ExpXZIMatrix, ExpXZXMatrix, ExpXZZMatrix, ExpXZYMatrix, ExpXYIMatrix, ExpXYXMatrix, ExpXYZMatrix, ExpXYYMatrix, ExpZIIMatrix, ExpZIXMatrix, ExpZIZMatrix, ExpZIYMatrix, ExpZXIMatrix, ExpZXXMatrix, ExpZXZMatrix, ExpZXYMatrix, ExpZZIMatrix, ExpZZXMatrix, ExpZZZMatrix, ExpZZYMatrix, ExpZYIMatrix, ExpZYXMatrix, ExpZYZMatrix, ExpZYYMatrix, ExpYIIMatrix, ExpYIXMatrix, ExpYIZMatrix, ExpYIYMatrix, ExpYXIMatrix, ExpYXXMatrix, ExpYXZMatrix, ExpYXYMatrix, ExpYZIMatrix, ExpYZXMatrix, ExpYZZMatrix, ExpYZYMatrix, ExpYYIMatrix, ExpYYXMatrix, ExpYYZMatrix, ExpYYYMatrix]
        ];
        return (functionLookup[len - 1])[index](t);
    }
    
}



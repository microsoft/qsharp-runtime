// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators.Circuits
{
    
    operation Ty (target : Qubit) : Unit
    is Adj {

        PauliZFlip(PauliY, target);
        InternalT(target);
        Adjoint PauliZFlip(PauliY, target);
    }
    
    /// # Remarks
    /// Here is Mathematica code to check the correctness of ControlledH implementation:
    /// ```
    /// H = {{1, 1}, {1, -1}}/Sqrt[2];
    /// T = DiagonalMatrix[{1, Exp[I Pi/4]}];
    /// S = DiagonalMatrix[{1, I}];
    /// Z = DiagonalMatrix[{1, -1}];
    /// Dagger = ConjugateTranspose;
    /// Ty = S.H.T.Dagger[ S.H];
    /// Ty.Z.Dagger[Ty] == H // Simplify
    /// ```
    operation ControlledH (control : Qubit, target : Qubit) : Unit
    is Adj {
        Adjoint Ty(target);
        CZ(control, target);
        Ty(target);
    }
    
}



// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators.Circuits
{
    
    /// # Summary
    /// Unitary version of Controlled-Controlled-Z, gate
    /// 
    /// # Input
    /// ## a
    /// the first qubit the operation acts on 
    /// ## b
    /// the second qubit the operation acts on
    /// ## c
    /// the third qubit the operation acts on
    /// 
    /// # Remarks
    /// CCZ = exp( -iπ|111⟩⟨111| ) = exp( -iπ((I-Z)/2)⊗((I-Z)/2)⊗((I-Z)/2) )
    /// = exp(-i π/2³ I⊗I⊗I) ×
    ///      exp( i π/2³ Z⊗I⊗I ) exp( i π/2³ I⊗Z⊗I ) exp( i π/2³ I⊗I⊗Z ) ×
    ///   exp(-i π/2³ Z⊗Z⊗I ) exp(-i π/2³ I⊗Z⊗Z ) exp(-i π/2³ Z⊗I⊗Z ) ×
    ///   exp( i π/2³ Z⊗Z⊗Z )
    /// Note that CCZ is symmetric with respect to all of its qubit arguments.
    operation CCZ (a : Qubit, b : Qubit, c : Qubit) : Unit
    {
        body (...)
        {
            // do not care about global phase because this CCZ implementation has no controlled version
            // this line and every line below uses 1 T gate
            InternalRzFrac(1, 3, a);
            InternalRzFrac(1, 3, b);
            InternalRzFrac(1, 3, c);
            ExpFracZZ(-1, 3, a, b);
            ExpFracZZ(-1, 3, b, c);
            ExpFracZZ(-1, 3, a, c);
            ExpFracZZZ(1, 3, a, b, c);
        }
        
        adjoint self;
    }
    
}



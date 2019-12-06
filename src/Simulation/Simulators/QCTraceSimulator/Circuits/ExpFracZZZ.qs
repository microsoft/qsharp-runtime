// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators.Circuits
{
    
    /// # Summary
    /// ExpFracZZZ is exp( i pi k/2ⁿ Z⊗Z⊗Z ) 
    /// 
    /// # Input
    /// ## numerator
    /// k 
    /// ## power
    /// n 
    /// ## a
    /// first target qubit
    /// ## b
    /// second target qubit
    /// ## c
    /// third target qubit
    /// 
    /// # Remarks
    /// Using the fact that C₁X₂ (I⊗Z) C₁X₂ = Z⊗Z
    /// exp( i pi k/2ⁿ Z⊗Z⊗Z ) = C₁X₂ exp( i pi k/2ⁿ I⊗Z⊗Z ) C₁X₂.
    /// Note that ExpFracZZZ is symmetric with respect to all of its qubit arguments.
    operation ExpFracZZZ (numerator : Int, power : Int, a : Qubit, b : Qubit, c : Qubit) : Unit
    is Adj {
        InternalCX(a, b);
        ExpFracZZ(numerator, power, b, c);
        InternalCX(a, b);
    }
    
}



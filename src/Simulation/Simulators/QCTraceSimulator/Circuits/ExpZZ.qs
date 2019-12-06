// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators.Circuits
{
    
    /// # Summary
    /// ExpFracZZ is exp( i φ Z⊗Z )
    /// 
    /// # Input
    /// ## angle
    /// φ
    /// ## a
    /// first target qubit
    /// ## b
    /// second target qubit
    /// 
    /// Remarks
    /// We use notation C₁X₂ for CNOT gate with the target
    /// on the second qubit and control on the first qubit.
    /// Using the fact that C₁X₂ (I⊗Z) C₁X₂ = Z⊗Z
    /// exp( i pi k/2ⁿ Z⊗Z ) = C₁X₂ exp( i pi k/2ⁿ I⊗Z ) C₁X₂.
    /// Note that ExpFracZZ is symmetric with respect to the first and second arguments.
    operation ExpZZ (angle : Double, a : Qubit, b : Qubit) : Unit
    is Adj {
        InternalCX(a, b);
        InternalRz(-2.0 * angle, b);
        InternalCX(a, b);
    }
    
}



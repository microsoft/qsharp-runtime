// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators.Circuits
{
    
    /// <summary> ExpFracZZ is exp( i π k/2ⁿ Z⊗Z ) </summary>
    /// <param name="numerator"> k </param>
    /// <param name="power"> n </param>
    /// <param name="a"> first target qubit </param>
    /// <param name="b"> second target qubit </param>
    /// <remarks>
    /// We use notation C₁X₂ for CNOT gate with the target
    /// on the second qubit and control on the first qubit.
    /// Using the fact that C₁X₂ (I⊗Z) C₁X₂ = Z⊗Z
    /// exp( i pi k/2ⁿ Z⊗Z ) = C₁X₂ exp( i pi k/2ⁿ I⊗Z ) C₁X₂.
    /// Note that ExpFracZZ is symmetric with respect to the first and second arguments.
    /// </remarks>
    operation ExpFracZZ (numerator : Int, power : Int, a : Qubit, b : Qubit) : Unit
    is Adj {
        // InternalU is the way to refer to the internal operation U provided by the machine
        InternalCX(a, b);
        InternalRzFrac(numerator, power, b);
        InternalCX(a, b);
    }
    
}



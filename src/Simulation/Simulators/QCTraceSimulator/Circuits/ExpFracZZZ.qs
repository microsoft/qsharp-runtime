namespace Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators.Circuits
{
    
    /// <summary> ExpFracZZZ is exp( i pi k/2ⁿ Z⊗Z⊗Z ) </summary>
    /// <param name="numerator"> k </param>
    /// <param name="power"> n </param>
    /// <param name="a"> first target qubit </param>
    /// <param name="b"> second target qubit </param>
    /// <param name="c"> third target qubit </param>
    /// <remarks> Using the fact that C₁X₂ (I⊗Z) C₁X₂ = Z⊗Z
    /// exp( i pi k/2ⁿ Z⊗Z⊗Z ) = C₁X₂ exp( i pi k/2ⁿ I⊗Z⊗Z ) C₁X₂.
    /// Note that ExpFracZZZ is symmetric with respect to all of its qubit arguments.
    /// </remarks>
    operation ExpFracZZZ (numerator : Int, power : Int, a : Qubit, b : Qubit, c : Qubit) : Unit
    is Adj {
        InternalCX(a, b);
        ExpFracZZ(numerator, power, b, c);
        InternalCX(a, b);
    }
    
}



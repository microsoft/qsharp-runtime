namespace Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators.Circuits
{
    
    /// <summary> Controlled-controlled -iX  </summary>
    operation CCminusIX (control1 : Qubit, control2 : Qubit, target : Qubit) : Unit
    is Adj {
        PauliZFlip(PauliX, target);
        CCminusIZ(control1, control2, target);
        Adjoint PauliZFlip(PauliX, target);
    }
    
}



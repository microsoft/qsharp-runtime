namespace Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators.Circuits
{
    
    operation MultiCX (control : Qubit, targets : Qubit[]) : Unit
    {
        body (...)
        {
            for (i in 0 .. Length(targets) - 1)
            {
                InternalCX(control, targets[i]);
            }
        }
        
        adjoint self;
    }
    
}



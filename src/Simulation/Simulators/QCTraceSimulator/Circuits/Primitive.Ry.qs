namespace Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators.Circuits
{
    
    operation Ry (angle : Double, target : Qubit) : Unit
    is Adj + Ctl {

        R(PauliY, angle, target);
    }
    
}



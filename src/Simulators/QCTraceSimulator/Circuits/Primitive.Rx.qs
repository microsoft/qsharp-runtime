namespace Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators.Circuits
{
    
    operation Rx (angle : Double, target : Qubit) : Unit
    is Adj + Ctl {

        R(PauliX, angle, target);
    }
    
}



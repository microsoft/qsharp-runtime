namespace Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators.Circuits
{
    
    operation Rz (angle : Double, target : Qubit) : Unit
    is Adj + Ctl {

        R(PauliZ, angle, target);
    }
    
}



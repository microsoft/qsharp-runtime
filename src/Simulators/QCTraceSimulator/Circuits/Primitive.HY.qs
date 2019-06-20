namespace Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators.Circuits
{
    operation HY (target : Qubit) : Unit
    is Adj + Ctl {

        H(target);
        S(target);
    }    
}



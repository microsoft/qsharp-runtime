namespace Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators.Circuits
{
    
    operation T (target : Qubit) : Unit
    is Adj + Ctl {

        body (...)
        {
            InternalT(target);
        }
        
        controlled (ctrls, ...)
        {
            MultiControlledFromOpAndSinglyCtrldOp(InternalT, ControlledT, ctrls, target);
        }
    }
    
}



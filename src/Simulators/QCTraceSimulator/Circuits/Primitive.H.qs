namespace Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators.Circuits
{
    
    operation H (target : Qubit) : Unit
    is Adj + Ctl {

        body (...)
        {
            InternalH(target);
        }
        
        controlled (ctrls, ...)
        {
            MultiControlledFromOpAndSinglyCtrldOp(InternalH, ControlledH, ctrls, target);
        }
    }
    
}



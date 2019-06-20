namespace Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators.Circuits
{
    
    operation CNOT (control : Qubit, target : Qubit) : Unit
    is Adj + Ctl {

        body (...)
        {
            InternalCX(control, target);
        }
        
        controlled (ctrls, ...)
        {
            MultiControlledFromOpAndSinglyCtrldOp2(InternalCX, CCX, ctrls, control, target);
        }
    }
    
}



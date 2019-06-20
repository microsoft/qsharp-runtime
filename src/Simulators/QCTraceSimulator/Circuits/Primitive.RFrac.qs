namespace Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators.Circuits
{
    
    operation RFrac (pauli : Pauli, numerator : Int, power : Int, target : Qubit) : Unit
    is Adj + Ctl {

        body (...)
        {
            InternalRFrac(pauli, numerator, power, target);
        }
        
        controlled (ctrls, ...)
        {
            let op = InternalRFrac(pauli, numerator, power, _);
            let ctrOp = ControlledRFrac(pauli, numerator, power, _, _);
            MultiControlledFromOpAndSinglyCtrldOp(op, ctrOp, ctrls, target);
        }
    }
    
}



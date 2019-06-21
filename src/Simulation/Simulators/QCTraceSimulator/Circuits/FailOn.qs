namespace Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators.Circuits
{
    
    ///<summary> Calls "fail message" when the first argument is True </summary>
    function FailOn (failIfTrue : Bool, message : String) : Unit
    {
        if (failIfTrue)
        {
            fail message;
        }
    }
    
}



namespace Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators.Circuits
{
    
    /// <summary> returns 'val' modulo modulus </summary>
    function Mod (value : Int, modulus : Int) : Int
    {
        let mod = value % modulus;        
        return mod < 0 ? mod + modulus | mod;
    }
    
}



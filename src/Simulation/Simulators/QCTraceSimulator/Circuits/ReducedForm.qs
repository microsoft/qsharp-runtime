namespace Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators.Circuits
{
    function _reducedFormRec (numerator : Int, power : Int) : (Int, Int)
    {
        if (Mod(numerator,2)== 1)
        {
            return (numerator,power);
        }

        return _reducedFormRec(numerator / 2, power - 1);
    }

    /// <summary> returns fraction j/2ᵐ represented as tuple (j,m) equal to k/2ⁿ such that j is odd
    /// when k is 0, returns (0,0) </summary>
    /// <param name="numerator"> k </param>
    /// <param name="power"> n </param>
    function ReducedForm (numerator : Int, power : Int) : (Int, Int)
    {
        if (numerator == 0)
        {
            return (0, 0);
        }

        return _reducedFormRec(numerator, power);
    }
}

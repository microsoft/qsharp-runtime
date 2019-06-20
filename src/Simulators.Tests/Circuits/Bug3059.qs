namespace Bug3059 {

    function CheckPair (fst : Int, snd : Int) : Unit { }

    function WithDiscardedSymbols (fct : ((Int, Int) -> Unit), arg : (Int, (Int, Int))[]) : Unit 
    {
        let _ = arg;
        let mapper = fct(1, _);         

        for (_ in arg) {
            for (_ in arg) {            
                for ((_, (i, _)) in arg) {
                
                    let partial = fct(i, _); 
                    partial(0); 
                }
            }
        }
        let _ = arg; 
        mapper(0); 
    }
}

namespace Microsoft.Quantum.Simulation.Simulators.Tests.Circuits
{
    open Bug3059;

    operation DiscardedSymbolsTest () : Unit {
        WithDiscardedSymbols(CheckPair, new (Int, (Int, Int))[5]); 
    }
}


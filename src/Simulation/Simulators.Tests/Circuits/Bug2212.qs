
namespace Bug2212 {

    function F<'T> (arg1 :'T , arg : Unit) : 'T {
        return arg1;
    }
 
    function RecursiveGeneric2<'T> (arg1 : (Unit -> 'T), arg2 : Int) : Int  {
        if ( arg2 <= 0 ) {
            return arg2; 
        } else {
            let _ = arg1();
            return RecursiveGeneric2<(Unit -> 'T)>(F(arg1,_),arg2 - 1);
        }
    }
}

namespace Microsoft.Quantum.Simulation.Simulators.Tests.Circuits
{
    open Bug2212;

    operation Bug2212Test () : Unit
    {
        // Calling this function used to trigger a run time exception.
        let x = RecursiveGeneric2(F(3,_), 10);
    }
}

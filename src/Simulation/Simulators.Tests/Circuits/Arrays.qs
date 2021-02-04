// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.Simulators.Tests.Circuits
{
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Intrinsic;
    
    operation MapF<'T, 'U> (mapper : ('T -> 'U), source : 'T[]) : 'U[] {
        
        mutable result = new 'U[Length(source)];
        
        for (i in 0 .. Length(source) - 1) {
            let m = mapper(source[i]);
            set result = result w/ i <- m;
        }
        
        return result;
    }
    

    operation LengthTest () : Unit
    {
        let a1 = [One, Zero];
        let a2 = [Zero, Zero, Zero];

        AssertEqual(2, Length(a1));
        AssertEqual(3, Length(a2));

        let values = MapF(Length<Result>, [a1, a2]);
        AssertEqual(2, values[0]);
        AssertEqual(3, values[1]);
    }

    @Test("QuantumSimulator")
    function SizedArray() : Unit {
        let xs = [true, size = 3];
        AssertEqual([true, true, true], xs);
    }
}

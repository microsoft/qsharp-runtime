// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.Simulators.Tests.Circuits {
    
    function Factorial (x : Int) : Int {
        
        
        if (x == 1) {
            return 1;
        }
        else {
            return x * Factorial(x - 1);
        }
    }
    
    
    operation OpFactorial (x : Int) : Int {
        
        
        if (x == 1) {
            return 1;
        }
        else {
            return x * OpFactorial(x - 1);
        }
    }
    
    
    function GenRecursion<'T> (x : 'T, cnt : Int) : 'T {
        
        
        if (cnt == 0) {
            return x;
        }
        else {
            return GenRecursion(x, cnt - 1);
        }
    }
    
    
    function GenRecursionPartial<'T> (x : 'T, cnt : Int) : 'T {
        
        
        if (cnt == 0) {
            return x;
        }
        else {
            let fct = GenRecursionPartial(_, cnt - 1);
            return fct(x);
        }
    }
    
}



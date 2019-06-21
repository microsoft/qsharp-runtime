// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.TestSuite.Math {
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Convert;

    function _pavRecursion (value : Int, valuationBase : Int, valuation : Int) : (Int, Int) {
        if (value % valuationBase != 0 ) {
            return (valuation, value);
        }
    
        return _pavRecursion(value / valuationBase, valuationBase, valuation + 1);
    }

    /// returns (a,b) where a is the biggest value such that value = b*valuationBase^a    
    function PAdicValuation (value : Int, valuationBase : Int) : (Int, Int) {
        if (value == 0) {
            fail $"value must be non-zero";
        }
        
        if (valuationBase <= 0) {
            fail $"valuationBase must be positive";
        }
        
        return _pavRecursion(value, valuationBase, 0);
    }
    
}



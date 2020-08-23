// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.TestSuite {
    open Microsoft.Quantum.Intrinsic;
    
    
    operation OneQubitOperationsTest () : Unit {
        
        let list = OneQubitTestList();
        
        for (test in OneQubitTestList()) {
            let shouldExecute =
                IsFullSimulator() or
                (IsStabilizerSimulator() and LevelOfCliffordHierarchy(test) <= 1) or
                (IsReversibleSimulator() and FixesComputationalBasis(test));
            
            if (shouldExecute) {
                let map = OperationMap(test);
                AssertQubitUnitaryWithAdjoint(OperationMatrix(test), map);
                Message($"Passed:{map}");
            }
        }
    }
    
}



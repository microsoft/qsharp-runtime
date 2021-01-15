// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.TestSuite {
    
    open Microsoft.Quantum.Simulation.TestSuite.Math;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Intrinsic;
    
    
    operation MultiControlledQubitTestHelper (qubitOperation : (Qubit => Unit is Ctl + Adj), controls : Int, target : Qubit[]) : Unit {
        
        body (...) {
            
            if (Length(target) != controls + 1) {
                fail $"expecting {controls}+1 qubits as input";
            }
            
            Controlled qubitOperation(target[1 .. controls], target[0]);
        }
        
        adjoint invert;
        controlled distribute;
        controlled adjoint distribute;
    }
    
    
    operation MultiControlledTestHelper (testOperation : (Qubit[] => Unit is Ctl + Adj), controlsCount : Int, targetCount : Int, target : Qubit[]) : Unit {
        
        body (...) {
            
            if (Length(target) != controlsCount + targetCount) {
                fail $"expecting {controlsCount}+{targetCount} qubits as input";
            }
            
            Controlled testOperation(target[targetCount .. (targetCount + controlsCount) - 1], target[0 .. targetCount - 1]);
        }
        
        adjoint invert;
        controlled distribute;
        controlled adjoint distribute;
    }
    
    
    operation MultiControlledQubitOperationsTester (controls : Int) : Unit {
        
        
        if (controls < 0) {
            fail $"number of controlls must be non-negative";
        }
        
        Message($"Testing with {controls} controls");
        
        for (test in OneQubitTestList()) {
            let shouldExecute =
                IsFullSimulator() or
                (IsStabilizerSimulator() and LevelOfCliffordHierarchy(test) + controls <= 1) or
                (IsReversibleSimulator() and FixesComputationalBasis(test));
            
            if (shouldExecute) {
                let map = OperationMap(test);
                
                using (qubits = Qubit[controls + 1]) {
                    AssertUnitaryWithAdjoint(ControlledMatrix(controls, OperationMatrix(test)), MultiControlledQubitTestHelper(map, controls, _), qubits);
                }
                
                Message($"Passed:{map}");
            }
        }
    }
    
}



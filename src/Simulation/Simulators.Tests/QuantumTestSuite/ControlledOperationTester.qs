// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.TestSuite {
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Diagnostics;
    
    
    operation ControlledQubitOperationTester (actual : (Qubit => Unit is Ctl + Adj), expected : (Qubit => Unit is Ctl + Adj), numberOfQubits : Int) : Unit {
        
        Message($"Testing operation: {actual} against {expected}");
        
        if (numberOfQubits < 1) {
            fail $"numberOfQubits must be at least 1";
        }
        
        let actualOnQubitArr = OnFirstQubitA(actual, _);
        let expectedOnQubitArr = OnFirstQubitA(expected, _);
        AssertOperationsEqualReferenced(1, actualOnQubitArr, expectedOnQubitArr);
        AssertOperationsEqualReferenced(1, Adjoint actualOnQubitArr, Adjoint expectedOnQubitArr);
        
        for (totalQubits in 1 .. numberOfQubits) {
            let controlsCount = totalQubits - 1;
            Message($"Testing equality of controlled version with {controlsCount} control(s)");
            let actualControlled = MultiControlledQubitTestHelper(actual, controlsCount, _);
            let expectedControlled = MultiControlledQubitTestHelper(expected, controlsCount, _);
            AssertOperationsEqualReferenced(totalQubits, actualControlled, expectedControlled);
            AssertOperationsEqualReferenced(totalQubits, Adjoint actualControlled, Adjoint expectedControlled);
        }
    }
    
    
    operation ControlledOperationTester (actual : (Qubit[] => Unit is Ctl + Adj), expected : (Qubit[] => Unit is Ctl + Adj), numberOfQubits : Int, numberOfControls : Int) : Unit {
        
        Message($"Testing operation: {actual} against {expected}");
        
        if (numberOfQubits < 1) {
            fail $"numberOfQubits must be at least 1";
        }
        
        AssertOperationsEqualReferenced(numberOfQubits, actual, expected);
        AssertOperationsEqualReferenced(numberOfQubits, Adjoint actual, Adjoint expected);
        
        for (controls in 0 .. numberOfControls) {
            Message($"Testing equality of controlled version with {controls} control(s)");
            let actualControlled = MultiControlledTestHelper(actual, controls, numberOfQubits, _);
            let expectedControlled = MultiControlledTestHelper(expected, controls, numberOfQubits, _);
            AssertOperationsEqualReferenced(controls + numberOfQubits, actualControlled, expectedControlled);
            AssertOperationsEqualReferenced(controls + numberOfQubits, Adjoint actualControlled, Adjoint expectedControlled);
        }
    }
    
}

// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.TestSuite.SelfTests {
    
    open Microsoft.Quantum.Simulation.TestSuite;
    open Microsoft.Quantum.Simulation.TestSuite.Math;
    open Microsoft.Quantum.Math;
    
    
    operation PauliExpectationTestHelper (testData : Int[]) : Unit {
        
        let len = Length(testData);
        
        if (len % 2 != 0) {
            fail $"testData must have even Length";
        }
        
        let half = len / 2;
        let observable = PauliById(testData[0 .. half - 1]);
        let stateIds = testData[half .. len - 1];
        let state = StateById(stateIds);
        let expected = ExpectedValueForMultiPauliByStateId(observable, stateIds);
        let given = PauliExpectation(observable, state);
        
        if (AbsD(expected - given) >= Accuracy()) {
            fail $"wrong expectation value";
        }
    }
    
    
    operation PauliExpectationTest () : Unit {
        
        let totalQubitsToTest = 4;
        
        for (i in 1 .. totalQubitsToTest) {
            let pauliesBound = MakeConstArray(i, NumberOfPaulies());
            let statesBound = MakeConstArray(i, NumberOfTestStates());
            IterateThroughCartesianProduct(pauliesBound + statesBound, PauliExpectationTestHelper);
        }
    }
    
}

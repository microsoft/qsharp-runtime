// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.QCTraceSimulatorPrimitivesTests {
    
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Simulation.TestSuite;
    open Microsoft.Quantum.Simulation.TestSuite.Math;
    
    
    operation TwoQubitOperationsWithControllsTest () : Unit {
        
        let phi = 0.1;
        let globalPhaseOp1 = _Decomposer_R(PauliI, phi, _);
        let rotationOp1 = R1(-phi / 2.0, _);
        let globalPhaseOp3 = _Decomposer_RFrac(PauliI, 1, 3, _);
        let rotationOp3 = R1Frac(1, 3, _);
        let globalPhaseOp2 = _Decomposer_Exp([PauliI], phi, _);
        let rotationOp2 = R1(phi, _);
        let globalPhaseOp4 = _Decomposer_ExpFrac([PauliI], 1, 3, _);
        let rotationOp4 = R1Frac(1, 3, _);
        let paramFreeList = [
            (MultiControlledQubitTestHelper(globalPhaseOp1, 1, _), OnSecondQubitAC(rotationOp1, _)),
            (MultiControlledQubitTestHelper(globalPhaseOp3, 1, _), OnSecondQubitAC(rotationOp3, _)),
            (MultiControlledTestHelper(globalPhaseOp2, 1, 1, _), OnSecondQubitAC(rotationOp2, _)), //
            (MultiControlledTestHelper(globalPhaseOp4, 1, 1, _), OnSecondQubitAC(rotationOp4, _)), //
            (OnFirstTwoQubitsAC(_Decomposer_CNOT, _), OnFirstTwoQubitsAC(CNOT, _)),
            (OnFirstTwoQubitsAC(_Decomposer_SWAP, _), OnFirstTwoQubitsAC(SWAP, _)),
            (_Decomposer_Exp([PauliI, PauliI], 0.0, _), Exp([PauliI, PauliI], 0.0, _)),
            (_Decomposer_ExpFrac([PauliI, PauliI], 0, 0, _), ExpFrac([PauliI, PauliI], 0, 0, _))
        ];
        
        for (i in 0 .. Length(paramFreeList) - 1) {
            let (actual, expected) = paramFreeList[i];
            ControlledOperationTester(actual, expected, 2, 5);
        }
        
        IterateThroughCartesianPower(2, NumberOfPaulies(), ExpTester);
    }
    
    
    operation ExpTester (pauliIds : Int[]) : Unit {

        let paulies = PauliById(pauliIds);
        let inputQubits = Length(paulies);
        let maxControls = 3;
        let phi = 0.1;
        let num = 1;
        let denom = 8;
        let testList = [
            (_Decomposer_Exp(paulies, phi, _), Exp(paulies, phi, _)), 
            (_Decomposer_ExpFrac(paulies, num, denom, _), ExpFrac(paulies, num, denom, _))
        ];
        
        for ((actual, expected) in testList) {
            ControlledOperationTester(actual, expected, inputQubits, maxControls);
        }
    }

}
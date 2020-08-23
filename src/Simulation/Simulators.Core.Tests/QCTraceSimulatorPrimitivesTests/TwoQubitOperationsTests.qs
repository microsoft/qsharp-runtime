// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.QCTraceSimulatorPrimitivesTests {
    
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Simulation.TestSuite;
    open Microsoft.Quantum.Simulation.TestSuite.Math;
    
    
    operation TwoQubitOperationsWithControllsTest () : Unit {
        
        let phi = 0.1;
        let globalPhaseOp1 = Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators.Circuits.R(PauliI, phi, _);
        let rotationOp1 = R1(-phi / 2.0, _);
        let globalPhaseOp3 = Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators.Circuits.RFrac(PauliI, 1, 3, _);
        let rotationOp3 = R1Frac(1, 3, _);
        let globalPhaseOp2 = Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators.Circuits.Exp([PauliI], phi, _);
        let rotationOp2 = R1(phi, _);
        let globalPhaseOp4 = Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators.Circuits.ExpFrac([PauliI], 1, 3, _);
        let rotationOp4 = R1Frac(1, 3, _);
        let paramFreeList = [
            (MultiControlledQubitTestHelper(globalPhaseOp1, 1, _), OnSecondQubitAC(rotationOp1, _)),
            (MultiControlledQubitTestHelper(globalPhaseOp3, 1, _), OnSecondQubitAC(rotationOp3, _)),
            (MultiControlledTestHelper(globalPhaseOp2, 1, 1, _), OnSecondQubitAC(rotationOp2, _)),
            (MultiControlledTestHelper(globalPhaseOp4, 1, 1, _), OnSecondQubitAC(rotationOp4, _)),
            (OnFirstTwoQubitsAC(Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators.Circuits.CNOT, _), OnFirstTwoQubitsAC(CNOT, _)),
            (OnFirstTwoQubitsAC(Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators.Circuits.SWAP, _), OnFirstTwoQubitsAC(SWAP, _)),
            (Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators.Circuits.Exp([PauliI, PauliI], 0.0, _), Exp([PauliI, PauliI], 0.0, _)),
            (Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators.Circuits.ExpFrac([PauliI, PauliI], 0, 0, _), ExpFrac([PauliI, PauliI], 0, 0, _))
        ];
        
        for (i in 0 .. Length(paramFreeList) - 1) {
            let (actual, expected) = paramFreeList[i];
            ControlledOperationTester(actual, expected, 2, 5);
        }
        
        IterateThroughCartesianPower(2, NumberOfPaulies(), ExpTester);
    }
    
    
    operation ExpTester (pauliIds : Int[]) : Unit {
        
        mutable allIdentities = true;
        
        for (i in 0 .. Length(pauliIds) - 1) {
            
            if (pauliIds[i] != 3) {
                set allIdentities = false;
            }
        }
        
        if (allIdentities) {
            return ();
            //TODO: remove this when known issues are fixed
        }
        
        let paulies = PauliById(pauliIds);
        let inputQubits = Length(paulies);
        let maxControls = 3;
        let phi = 0.1;
        let num = 1;
        let denom = 8;
        let testList = [
            (Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators.Circuits.Exp(paulies, phi, _), Exp(paulies, phi, _)), 
            (Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators.Circuits.ExpFrac(paulies, num, denom, _), ExpFrac(paulies, num, denom, _))
        ];
        
        for (i in 0 .. Length(testList) - 1) {
            let (actual, expected) = testList[i];
            ControlledOperationTester(actual, expected, inputQubits, maxControls);
        }
    }
    
}



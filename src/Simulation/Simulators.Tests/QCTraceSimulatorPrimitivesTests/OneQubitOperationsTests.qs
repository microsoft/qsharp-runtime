// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.QCTraceSimulatorPrimitivesTests {
    
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Simulation.TestSuite;
    
    
    operation SingleQubitOperationsWithControlsTest () : Unit {
        
        
        // TODO: add (Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators.Circuits.HY, HY);
        // below, when HY is added to standard.qb
        let paramFreeList = [
            (Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators.Circuits.H, H),
            (Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators.Circuits.X, X),
            (Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators.Circuits.Z, Z),
            (Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators.Circuits.S, S),
            (Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators.Circuits.Y, Y),
            (Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators.Circuits.T, T)
        ];
        let rList = [
            (Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators.Circuits.RFrac(PauliZ, 1,0,_), RFrac(PauliZ,1,0,_)),
            (Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators.Circuits.RFrac(PauliZ, 1,1,_), RFrac(PauliZ,1,1,_)),
            (Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators.Circuits.RFrac(PauliZ, 1,2,_), RFrac(PauliZ,1,2,_)),
            (Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators.Circuits.RFrac(PauliZ, 1,3,_), RFrac(PauliZ,1,3,_)),
            (Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators.Circuits.RFrac(PauliZ, 1,4,_), RFrac(PauliZ,1,4,_)),
            (Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators.Circuits.Rz(0.1,_), Rz(0.1,_)),
            (Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators.Circuits.Ry(0.1,_), Ry(0.1,_)),
            (Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators.Circuits.Rx(0.1,_), Rx(0.1,_)),
            (Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators.Circuits.R1Frac(1,0,_), R1Frac(1,0,_)),
            (Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators.Circuits.R1Frac(1,1,_), R1Frac(1,1,_)),
            (Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators.Circuits.R1Frac(1,2,_), R1Frac(1,2,_)),
            (Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators.Circuits.R1Frac(1,3,_), R1Frac(1,3,_)),
            (Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators.Circuits.R1Frac(1,4,_), R1Frac(1,4,_))
        ];
        let testList = paramFreeList + rList;
        
        for (i in 0 .. Length(testList) - 1) {
            let (actual, expected) = testList[i];
            ControlledQubitOperationTester(actual, expected, 3);
        }
        
        for (i in 0 .. Length(paramFreeList) - 1) {
            let (actual, expected) = paramFreeList[i];
            ControlledQubitOperationTester(actual, expected, 5);
        }
    }
    
    
    operation SingleQubitRotationsWithOneControlTest () : Unit {
        
        mutable testList = [
            (Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators.Circuits.R1(0.1,_), R1(0.1,_)),  
            (Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators.Circuits.Rz(0.1,_), Rz(0.1,_)),
            (Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators.Circuits.Ry(0.1,_), Ry(0.1,_)),
            (Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators.Circuits.Rx(0.1,_), Rx(0.1,_))
        ];

        //TODO: add PauliI here when known issues are fixed
        let paulies = [PauliX, PauliY, PauliZ];
        
        for (k in 0 .. 2) {
            let pauli = paulies[k];
            let phi = 0.1;
            let opExpected = Exp([paulies[k]], phi, _);
            let opActual = Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators.Circuits.Exp([paulies[k]], phi, _);
            set testList = testList + [(Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators.Circuits.R(pauli, phi, _), R(pauli, phi, _)), (OnOneQubitAC(opActual, _), OnOneQubitAC(opExpected, _))];
        }
        
        for (i in 0 .. 4) {
            
            for (j in -2 ^ i .. 2 ^ i) {
                set testList = testList + [(Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators.Circuits.R1Frac(j, i, _), R1Frac(j, i, _))];
                
                for (k in 0 .. 2) {
                    let opExpected = ExpFrac([paulies[k]], j, i, _);
                    let opActual = Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators.Circuits.ExpFrac([paulies[k]], j, i, _);
                    set testList = testList + [(Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators.Circuits.RFrac(paulies[k], j, i, _), RFrac(paulies[k], j, i, _)), (OnOneQubitAC(opActual, _), OnOneQubitAC(opExpected, _))];
                }
            }
        }
        
        for (i in 0 .. Length(testList) - 1) {
            let (actual, expected) = testList[i];
            ControlledQubitOperationTester(actual, expected, 2);
        }
    }
    
}



// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.TestSuite {
    
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Simulation.TestSuite.Math;
    
    
    operation AssertProbMultiQubit1Test () : Unit {
        
        AssertProbForStateAndObservable([PauliI, PauliI], [0, 1]);
    }
    
    
    operation AssertProbMultiQubit2Test () : Unit {
        
        AssertProbForStateAndObservable([PauliI, PauliX], [1, 2]);
    }
    
    
    operation ControlledExpWithIPauliTest () : Unit {
        
        let controls = 1;
        let phi = 0.1;
        let pauli = PauliI;
        let testOp = Exp([pauli], phi, _);
        let matrix = ControlledMatrix(controls, ExpPauliMatrix(pauli, phi));
        let op = OnOneQubitAC(testOp, _);
        let controlledOp = MultiControlledQubitTestHelper(op, controls, _);
        
        using (qubits = Qubit[2]) {
            AssertUnitaryWithAdjoint(matrix, controlledOp, qubits);
        }
    }
    
    
    operation FracEdgeCasesQSimFail () : Unit {
        
        let rzPlus = RFrac(PauliZ, 1, 0xFFFFFFFFFFFFFFF, _);
        let rxPlus = RFrac(PauliX, 1, 0xFFFFFFFFFFFFFFF, _);
        let ryPlus = RFrac(PauliY, 1, 0xFFFFFFFFFFFFFFF, _);
        let rzMinus = RFrac(PauliZ, 1, -0xFFFFFFFFFFFFFFF, _);
        let rxMinus = RFrac(PauliX, 1, -0xFFFFFFFFFFFFFFF, _);
        let ryMinus = RFrac(PauliY, 1, -0xFFFFFFFFFFFFFFF, _);
        
        using (qubits = Qubit[1]) {
            AssertUnitaryWithAdjoint(IdentityMatrix(2), OnFirstQubitA(rxPlus, _), qubits);
            AssertUnitaryWithAdjoint(IdentityMatrix(2), OnFirstQubitA(ryPlus, _), qubits);
            AssertUnitaryWithAdjoint(IdentityMatrix(2), OnFirstQubitA(rzPlus, _), qubits);
            AssertUnitaryWithAdjoint(IdentityMatrix(2), OnFirstQubitA(rxMinus, _), qubits);
            AssertUnitaryWithAdjoint(IdentityMatrix(2), OnFirstQubitA(ryMinus, _), qubits);
            AssertUnitaryWithAdjoint(IdentityMatrix(2), OnFirstQubitA(rzMinus, _), qubits);
        }
    }
    
}



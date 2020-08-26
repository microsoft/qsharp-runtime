// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.TestSuite {
    open Microsoft.Quantum.Simulation.TestSuite.Math;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Diagnostics;
    
    
    newtype QubitOperationMatrixPair = ((Qubit => Unit), RowMajorMatrix);
    
    
    operation CheckJointState (inputStateId : Int[], operationsToTest : QubitOperationMatrixPair[], qubits : Qubit[]) : Unit {
        
        let numQubits = Length(qubits);
        
        if (Length(inputStateId) != Length(operationsToTest)) {
            fail $"Length(inputStateId) and Length(operationsToTest) must be equal";
        }
        
        if (Length(inputStateId) != numQubits) {
            fail $"Length(inputStateId) and Length(operationsToTest) must be equal";
        }
        
        mutable states = new Vector[numQubits];
        FlipToBasis(inputStateId, qubits);
        
        for (i in 0 .. numQubits - 1) {
            let (op, matrix) = operationsToTest[i]!;
            set states = states w/ i <- ApplyMatrix(matrix, StateIdToVector(inputStateId[i]));
            op(qubits[i]);
        }
        
        AssertState(TensorProductOfArray(states), qubits);
        ResetAll(qubits);
    }
    
    
    operation JointOneQubitTester (operationsToTest : QubitOperationMatrixPair[]) : Unit {
        
        let totalQubits = Length(operationsToTest);
        
        using (qubits = Qubit[totalQubits]) {
            let checkOperation = CheckJointState(_, operationsToTest, qubits);
            IterateThroughCartesianPower(totalQubits, NumberOfTestStates(), checkOperation);
        }
    }
    
    
    operation JointOneQubitTest () : Unit {
        
        
        if (IsStabilizerSimulator()) {
            
            if (IsFullSimulator()) {
                JointOneQubitTester([QubitOperationMatrixPair(H, HMatrix()), QubitOperationMatrixPair(T, TMatrix())]);
            }
            
            JointOneQubitTester([QubitOperationMatrixPair(H, HMatrix()), QubitOperationMatrixPair(H, HMatrix())]);
            JointOneQubitTester([QubitOperationMatrixPair(H, HMatrix()), QubitOperationMatrixPair(H, HMatrix()), QubitOperationMatrixPair(S, SMatrix())]);
        }
        
        JointOneQubitTester([QubitOperationMatrixPair(X, PauliMatrix(PauliX)), QubitOperationMatrixPair(X, PauliMatrix(PauliX)), QubitOperationMatrixPair(X, PauliMatrix(PauliX))]);
    }
    
}



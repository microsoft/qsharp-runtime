// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.TestSuite {
    open Microsoft.Quantum.Simulation.TestSuite.Math;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Diagnostics;
    
    
    operation AssertUnitaryHelper (stateIds : Int[], unitaryMatrix : RowMajorMatrix, unitaryOp : (Qubit[] => Unit), qubits : Qubit[]) : Unit {
        
        let expectedState = ApplyMatrix(unitaryMatrix, StateById(stateIds));
        _flipToBasis(stateIds, qubits);
        unitaryOp(qubits);
        AssertState(expectedState, qubits);
        ResetAll(qubits);
    }
    
    
    operation AssertUnitary (unitaryMatrix : RowMajorMatrix, unitaryOp : (Qubit[] => Unit), qubits : Qubit[]) : Unit {
        
        mutable bound = NumberOfComputationalBasisTestStates();
        
        if (IsStabilizerSimulator()) {
            set bound = NumberOfTestStates();
            //check only computational basis for reversible target
        }
        
        let checkOperation = AssertUnitaryHelper(_, unitaryMatrix, unitaryOp, qubits);
        IterateThroughCartesianPower(Length(qubits), bound, checkOperation);
    }
    
    
    operation AssertUnitaryWithAdjoint (unitaryMatrix : RowMajorMatrix, unitaryOp : (Qubit[] => Unit is Adj), qubits : Qubit[]) : Unit {
        
        
        if (Length(unitaryMatrix!) != 2 ^ Length(qubits)) {
            fail $"number of matrix rows must be 2^Length(qubits)";
        }
        
        AssertUnitaryMatrix(unitaryMatrix);
        AssertUnitary(unitaryMatrix, unitaryOp, qubits);
        
        (
            IsStabilizerSimulator()
            ? AssertOperationsEqualInPlace
            | AssertOperationsEqualInPlaceCompBasis
        )(Length(qubits), unitaryOp, unitaryOp);
    }
    
}



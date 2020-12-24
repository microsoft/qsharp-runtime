// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.TestSuite {
    
    open Microsoft.Quantum.Simulation.TestSuite.Math;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Diagnostics;
    
    
    operation AssertQubitUnitary (unitaryMatrix : RowMajorMatrix, unitaryOp : (Qubit => Unit), qubit : Qubit) : Unit {
        // check only computational basis for reversible target
        let maxId = IsStabilizerSimulator() ? 3 | 1;

        for (stateId in 0 .. maxId) {
            let expectedState = ApplyMatrix(unitaryMatrix, StateIdToVector(stateId));
            _flipToBasis([stateId], [qubit]);
            unitaryOp(qubit);
            let alpha = Microsoft.Quantum.Math.Complex((expectedState![0])!);
            let beta = Microsoft.Quantum.Math.Complex((expectedState![1])!);
            AssertQubitIsInStateWithinTolerance((alpha, beta), qubit, Accuracy());
            Reset(qubit);
        }
    }
    
    
    operation AssertQubitUnitaryWithAdjoint (unitaryMatrix : RowMajorMatrix, unitaryOp : (Qubit => Unit is Adj)) : Unit {
        
        if (Length(unitaryMatrix!) != 2) {
            fail $"qubit unitary matrix must have two rows";
        }
        
        let totalQubits = MaxQubitsToAllocateForOneQubitTests();
        AssertUnitaryMatrix(unitaryMatrix);
        
        using (qubits = Qubit[totalQubits]) {
            for (activeQubitId in 0 .. totalQubits - 1) {
                let qubit = qubits[activeQubitId];
                AssertQubitUnitary(unitaryMatrix, unitaryOp, qubit);
                let op = OnFirstQubitA(unitaryOp, _);

                if (IsStabilizerSimulator()) {
                    //this checks that the adjoint is correct
                    AssertOperationsEqualInPlace(1, op, op);
                } else {
                    AssertOperationsEqualInPlaceCompBasis(1, op, op);
                }
            }
        }
    }
    
}



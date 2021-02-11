// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.TestSuite {    
    open Microsoft.Quantum.Simulation.TestSuite.Math;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Intrinsic;
    
    
    operation TwoQubitUnitaryTestHelper (matrix : RowMajorMatrix, unitary : (Qubit[] => Unit is Adj)) : Unit {
        let totalQubits = MaxQubitsToAllocateForTwoQubitTests();
        
        using (qubits = Qubit[totalQubits]) {            
            for (i in 0 .. totalQubits - 1) {
                for (j in 0 .. totalQubits - 1) {
                    if (i != j) {
                        AssertUnitaryWithAdjoint(matrix, unitary, [qubits[i], qubits[j]]);
                    }
                }
            }
        }
    }
    
    
    operation CNOTTestHelper (qubits : Qubit[]) : Unit is Adj {
        if (Length(qubits) != 2) {
            fail $"operation expects 2 qubits";
        }
        
        CNOT(qubits[0], qubits[1]);
    }
    
    
    operation CNOTTwoQubitTest () : Unit {
        TwoQubitUnitaryTestHelper(CNOTMatrix(), CNOTTestHelper);
    }
    
    
    operation SWAPTestHelper (qubits : Qubit[]) : Unit is Adj {
        if (Length(qubits) != 2) {
            fail $"operation expects 2 qubits";
        }
        
        SWAP(qubits[0], qubits[1]);
    }
    
    
    operation SWAPTwoQubitTest () : Unit {
        TwoQubitUnitaryTestHelper(SWAPMatrix(), SWAPTestHelper);
    }
    
    
    operation ExpTwoQubitTestHelper (pauliIds : Int[]) : Unit {
        
        let pauli = PauliById(pauliIds);
        Message($"{pauli}");
        TwoQubitUnitaryTestHelper(ExpMultiPauliMatrix(pauli, 0.1), Exp(pauli, 0.1, _));
    }
    
    
    operation ExpTwoQubitTest () : Unit {
        
        
        if (IsFullSimulator()) {
            IterateThroughCartesianPower(2, NumberOfPaulies(), ExpTwoQubitTestHelper);
        }
    }
    
    
    operation ControlledTestHelper (qubitOperation : (Qubit => Unit is Ctl + Adj), target : Qubit[]) : Unit {
        
        body (...) {
            
            if (Length(target) != 2) {
                fail $"expecting 2 qubits as input";
            }
            
            Controlled qubitOperation([target[1]], target[0]);
        }
        
        adjoint invert;
    }
    
    
    operation ControlledOneQubitOperationsTwoQubitTest () : Unit {
        for (test in OneQubitTestList()) {
            let shouldExecute =
                IsFullSimulator() or
                (IsStabilizerSimulator() and LevelOfCliffordHierarchy(test) <= 0) or
                (IsReversibleSimulator() and FixesComputationalBasis(test));
            
            if (shouldExecute) {
                let map = OperationMap(test);
                TwoQubitUnitaryTestHelper(ControlledMatrix(1, OperationMatrix(test)), ControlledTestHelper(map, _));
                Message($"Passed:{map}");
            }
        }
    }
    
}



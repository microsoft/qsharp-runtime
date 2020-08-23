// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.TestSuite.VeryLong {
    
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Simulation.TestSuite;
    open Microsoft.Quantum.Simulation.TestSuite.Math;
    open Microsoft.Quantum.Math;
    
    
    operation ExpTestHelper (pauliIds : Int[]) : Unit {
        let pauli = PauliById(pauliIds);
        
        using (qubits = Qubit[Length(pauliIds)]) {
            AssertUnitaryWithAdjoint(ExpMultiPauliMatrix(pauli, 0.1), Exp(pauli, 0.1, _), qubits);
        }
    }
    
    
    operation ExpThreeQubitTest () : Unit {
        if (IsFullSimulator()) {
            IterateThroughCartesianPower(3, NumberOfPaulies(), ExpTestHelper);
        }
    }
    
    
    operation OneQubitUnitariesWithTwoControlsTest () : Unit {
        MultiControlledQubitOperationsTester(2);
    }
    
}



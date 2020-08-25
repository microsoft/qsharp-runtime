// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.Simulators.Tests.Circuits {
    
    open Microsoft.Quantum.Intrinsic;
    
    
    operation JointMeasureTest () : Unit {
        
        
        using (qubits = Qubit[3]) {
            let q1 = qubits[0];
            let q2 = qubits[1];
            let q3 = qubits[2];
            let basis = [PauliZ, PauliZ, PauliZ];
            let r1 = Measure(basis, qubits);
            AssertEqual(Zero, r1);
            X(q1);
            let r2 = Measure(basis, qubits);
            AssertEqual(One, r2);
            AssertEqual(One, Measure([PauliZ], [q1]));
            AssertEqual(Zero, Measure([PauliZ], [q2]));
            AssertEqual(Zero, Measure([PauliZ], [q3]));
            X(q3);
            let r3 = Measure(basis, qubits);
            AssertEqual(Zero, r3);
            AssertEqual(One, Measure([PauliZ], [q1]));
            AssertEqual(Zero, Measure([PauliZ], [q2]));
            AssertEqual(One, Measure([PauliZ], [q3]));
            X(q2);
            let r4 = Measure(basis, qubits);
            AssertEqual(One, r4);
            AssertEqual(One, Measure([PauliZ], [q1]));
            AssertEqual(One, Measure([PauliZ], [q2]));
            AssertEqual(One, Measure([PauliZ], [q3]));
            ResetAll(qubits);
        }
    }
    
}



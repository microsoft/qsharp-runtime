// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.Simulators.Tests.Circuits {
    
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Simulation.TestSuite;
    
    
    /// <summary>
    ///     Verifies that all operations of the one-qubit Unitary work.
    ///     It receives as parameter the Unitary (notice that any gate can be converted to Unitary
    ///     using Partial Application), a start state that the qubit should be initialized with,
    ///     and the qubit state that the Qubit should be at
    ///     once the Unitary has been applied.
    ///     The verification applies the gate and asserts the qubit state. Then it applies
    ///     the Adjoint and verifies the qubit is back to Zero.
    ///     then it tests Controlled with different number of control qubits, also verifying that
    ///     Adjoint Controlled works.
    /// </summary>
    operation VerifyUnitary (gate : (Qubit => Unit is Adj + Ctl), start : (Pauli, Result), expected : (Complex, Complex)) : Unit {
        
        
        using (qubits = Qubit[1]) {
            let tolerance = 1E-05;
            let q1 = qubits[0];
            let (a, b) = expected;
            let (p, r) = start;
            SetQubit(r, q1);
            
            if (p == PauliX) {
                H(q1);
            }
            
            // Make sure we start in correct state.
            Assert([p], [q1], r, $"Qubit in invalid state.");
            
            // Apply the gate, make sure it's in the right state
            gate(q1);
            AssertQubitIsInStateWithinTolerance(expected, q1, tolerance);
            
            // Apply Adjoint, back to Zero:
            Adjoint gate(q1);
            Assert([p], [q1], r, $"Qubit in invalid state.");
            
            // When no control qubits, it should be equivalent to just calling the gate:
            Controlled gate(new Qubit[0], q1);
            AssertQubitIsInStateWithinTolerance(expected, q1, tolerance);
            
            // Apply Adjoint, back to Zero:
            Controlled (Adjoint gate)(new Qubit[0], q1);
            Assert([p], [q1], r, $"Qubit in invalid state.");
            
            // Now test control... We'll have 3 control qubits.
            // We will run the test with 1..3 controls at a time.
            let ctrlsCount = 3;
            
            using (ctrls = Qubit[ctrlsCount]) {
                
                for (i in 0 .. ctrlsCount - 1) {
                    
                    // We're starting fresh
                    Assert([p], [q1], r, $"Qubit in invalid state.");
                    
                    // Get a subset for control and initialize them to zero:
                    let c = ctrls[0 .. i];
                    
                    for (j in 0 .. i) {
                        SetQubit(Zero, c[j]);
                    }
                    
                    // Noop when ctrls are all zero.
                    Controlled gate(c, q1);
                    Assert([p], [q1], r, $"Qubit in invalid state.");
                    
                    // turn on each of the controls one by one
                    for (j in 1 .. Length(c)) {
                        X(c[j - 1]);
                        Controlled gate(c, q1);
                        
                        // Only when all
                        if (j == Length(c)) {
                            AssertQubitIsInStateWithinTolerance(expected, q1, tolerance);
                        }
                        else {
                            Assert([p], [q1], r, $"Qubit in invalid state.");
                        }
                        
                        Adjoint Controlled gate(c, q1);
                    }
                }
                
                ResetAll(ctrls);
            }
            
            // We're back where we started.
            Assert([p], [q1], r, $"Qubit in invalid state.");
            SetQubit(r, q1);
            ResetAll(qubits);
        }
    }
    
}



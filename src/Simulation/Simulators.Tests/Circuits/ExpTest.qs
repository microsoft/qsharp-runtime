// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.Simulators.Tests.Circuits {
    
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Math;
    
    // At some point, this was causing the simulator to crash.
    
    operation ExpCrashTest () : Unit {
        
        
        using (qubits = Qubit[3]) {
            let q1 = qubits[0];
            let q2 = qubits[1];
            let ctrls = qubits[2 .. 2];
            Exp([PauliZ], 0.5678, [q1]);
            Controlled Exp(ctrls, ([PauliZ], 0.5678, [q1]));
            Exp([PauliZ, PauliZ], 0.6799, [q1, q2]);
            Controlled Exp(ctrls, ([PauliZ, PauliZ], 0.6799, [q1, q2]));
            
            // Make sure all allocated qubits are measured before release
            let (r1, r2, r3) = (M(q1), M(q2), M(ctrls[0]));
            X(q1);
            ResetAll(qubits);
        }
    }
    
    operation VerifyExpUsingDecompositions() : Unit {
        AssertOperationsEqualReferenced(2, (qs => SwapFromExp(qs[0], qs[1])), (qs => SWAP(qs[0], qs[1])));
        AssertOperationsEqualReferenced(2, (qs => CnotFromExp(qs[0], qs[1])), (qs => CNOT(qs[0], qs[1])));
    }

    operation SwapFromExp(q0 : Qubit, q1 : Qubit) : Unit is Adj + Ctl {
        let qs = [q0, q1];
        let theta = PI() / 4.0;
        Exp([PauliI, PauliI], theta, qs);
        Exp([PauliX, PauliX], theta, qs);
        Exp([PauliY, PauliY], theta, qs);
        Exp([PauliZ, PauliZ], theta, qs);
    }

    operation CnotFromExp(q0 : Qubit, q1 : Qubit) : Unit is Adj + Ctl {
        let qs = [q0, q1];
        let theta = PI() / 4.0;
        Exp([PauliI, PauliI], theta, qs);
        Exp([PauliI, PauliX], theta, qs);
        Exp([PauliZ, PauliI], theta, qs);
        Adjoint Exp([PauliZ, PauliX], theta, qs);
    }
}



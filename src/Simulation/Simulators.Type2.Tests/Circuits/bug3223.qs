// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.Simulators.Tests.Circuits
{
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Diagnostics;
 
    operation F2 (x : Qubit[], y : Qubit) : Unit {
        F1(x, y);
    }
 
    operation F1 (x : Qubit[], y : Qubit) : Unit {
        if (Length(x) > 1) {
            F2(x[0..Length(x)-2], y);
        }
        else {
            X(y);
        }
    }
 
    operation Solve (x : Qubit[], y : Qubit) : Unit
    {
        F1(x, y);
    }

    operation MutuallyRecursiveOperationTest () : Unit {

        using (qubits = Qubit[4]) {
            let x = qubits[0..2];
            let y = qubits[3];

            Solve(x, y);
            AssertQubit(One, y);

            ResetAll(qubits);
        }
    }
}
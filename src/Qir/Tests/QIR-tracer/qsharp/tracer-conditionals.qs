// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Testing.Tracer {
    open Microsoft.Quantum.Intrinsic;

    // Private helper operations.
    operation Delay(op : (Qubit => Unit), arg : Qubit, aux : Unit) : Unit {
        op(arg);
    }

    @EntryPoint()
    operation TestMeasurements() : Unit {
        use qs = Qubit[6];
        T(qs[0]); // layer 0
        let r0 = M(qs[0]); // layer 1
        T(qs[1]); // layer 0
        CNOT(qs[1], qs[2]); // layer 1
        let qs12 = [qs[1], qs[2]];
        let r12 = Measure([PauliY, PauliX], qs12); // layer 2

        ApplyIfElseIntrinsic(r0, Delay(X, qs[3], _), Delay(Y, qs[3], _)); // layers 2, 3
        ApplyIfElseIntrinsic(r12, Delay(Z, qs[4], _), Delay(S, qs[4], _)); // layer 3, 4
        Rx(4.2, qs[5]); // layer 0
    }
}
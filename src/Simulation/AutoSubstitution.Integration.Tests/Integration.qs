// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace Microsoft.Quantum.AutoSubstitution.Testing {
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Measurement;
    open Microsoft.Quantum.Targeting;

    @SubstitutableOnTarget("Microsoft.Quantum.Intrinsic.SWAP", "ToffoliSimulator")
    operation QuantumSwap(a : Qubit, b : Qubit) : Unit {
        within {
            CNOT(a, b);
            H(a);
            H(b);
        } apply {
            CNOT(a, b);
        }
    }

    operation TestQuantumSwap() : Unit {
        use a = Qubit();
        use b = Qubit();

        X(a);

        QuantumSwap(a, b);

        if MResetZ(a) != Zero {
            fail "unexpected value for a after swap";
        }
        if MResetZ(b) != One {
            fail "unexpected value for b after swap";
        }
    }
}

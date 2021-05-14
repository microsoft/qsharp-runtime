// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.
namespace Microsoft.Quantum.Testing.QIR {
    open Microsoft.Quantum.Intrinsic;

    @EntryPoint()
    operation TestQubitResultManagement() : Unit {
        // exercise __quantum__rt__qubit_allocate_array
        use qs = Qubit[2] {
            X(qs[1]);
            // exercise __quantum__rt__qubit_allocate
            use q = Qubit() {
                // exercise __quantum__rt__result_equal and accessing result constants
                if (M(qs[1]) == One) { X(q); }
                if (M(qs[0]) == M(q)) { fail("Unexpected measurement result"); }
            } // exercise __quantum__rt__qubit_release
        } // exercise __quantum__rt__qubit_release_array
    }
}
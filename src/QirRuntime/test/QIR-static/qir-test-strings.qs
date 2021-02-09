// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Testing.QIR.Str {

    open Microsoft.Quantum.Intrinsic;

    function PauliToStringTest() : Int {

        mutable pauli   = PauliI;
        mutable str     = $"Pauli value: {pauli}";
        if "Pauli value: PauliI" != str      { return 1; }     // The return value indicates which test case has failed.

        set pauli       = PauliX;
        set str         = $"{pauli}";
        if "PauliX" != str     { return 2; }

        set pauli       = PauliY;
        set str         = $"{pauli}";
        if "PauliY" != str     { return 3; }

        set pauli       = PauliZ;
        set str         = $"{pauli}";
        if "PauliZ" != str     { return 4; }

        return 0;
    }

}


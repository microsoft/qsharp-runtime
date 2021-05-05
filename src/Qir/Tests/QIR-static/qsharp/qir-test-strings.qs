// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Testing.QIR.Str {

    open Microsoft.Quantum.Intrinsic;

    @EntryPoint()
    function PauliToStringTest() : Int {

        if "Pauli value: PauliI" != 
            $"Pauli value: {PauliI}"   { return 1; }     // The return value indicates which test case has failed.
        if "PauliX" != $"{PauliX}"     { return 2; }
        if "PauliY" != $"{PauliY}"     { return 3; }
        if "PauliZ" != $"{PauliZ}"     { return 4; }

        return 0;
    }

}


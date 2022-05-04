// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Experimental.Decompositions {
    open Microsoft.Quantum.Experimental.Native as Native;

    internal function IsAnyPauliI(bases : Pauli[]) : Bool {
        for basis in bases {
            if basis == PauliI {
                return true;
            }
        }
        return false;
    }

    internal operation MapPauli(qubit : Qubit, from : Pauli, to : Pauli) : Unit is Adj {
        if (from == to) {
        }
        elif ((from == PauliZ and to == PauliX) or (from == PauliX and to == PauliZ)) {
            H(qubit);
        }
        elif (from == PauliZ and to == PauliY) {
            H(qubit);
            S(qubit);
            H(qubit);
        }
        elif (from == PauliY and to == PauliZ) {
            H(qubit);
            Adjoint S(qubit);
            H(qubit);
        }
        elif (from == PauliY and to == PauliX) {
            S(qubit);
        }
        elif (from == PauliX and to == PauliY) {
            Adjoint S(qubit);
        }
        else {
            fail "Unsupported input";
        }
    }

}

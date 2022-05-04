// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Experimental.Decompositions {
    open Microsoft.Quantum.Experimental.Native as Native;
    open Microsoft.Quantum.Experimental.Intrinsic as Intrinsic;

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
            Intrinsic.H(qubit);
        }
        elif (from == PauliZ and to == PauliY) {
            Intrinsic.H(qubit);
            Intrinsic.S(qubit);
            Intrinsic.H(qubit);
        }
        elif (from == PauliY and to == PauliZ) {
            Intrinsic.H(qubit);
            Adjoint Intrinsic.S(qubit);
            Intrinsic.H(qubit);
        }
        elif (from == PauliY and to == PauliX) {
            Intrinsic.S(qubit);
        }
        elif (from == PauliX and to == PauliY) {
            Adjoint Intrinsic.S(qubit);
        }
        else {
            fail "Unsupported input";
        }
    }

}

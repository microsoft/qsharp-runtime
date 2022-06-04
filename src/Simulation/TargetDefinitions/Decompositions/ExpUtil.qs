// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Intrinsic {

    internal operation ExpUtil (paulis : Pauli[], theta : Double, qubits : Qubit[], rotation : ((Pauli, Qubit) => Unit is Adj + Ctl)) : Unit is Ctl {
        if (Length(paulis) != Length(qubits)) { fail "Arrays 'paulis' and 'qubits' must have the same length"; }
        if (Length(paulis) == 1) {
            rotation(paulis[0], qubits[0]);
        }
        else { // Length(paulis) > 1 
            within {
                for i in 0 .. Length(paulis) - 1 {
                    MapPauli(qubits[i], PauliZ, paulis[i]);
                }
            }
            apply {
                within {
                    SpreadZ(qubits[0], qubits[ 1 .. Length(qubits) - 1]);
                }
                apply {
                    rotation(PauliZ, qubits[0]);
                }
            }
        }
    }


}
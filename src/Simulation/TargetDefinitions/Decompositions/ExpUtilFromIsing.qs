// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Intrinsic {

    internal operation ExpUtil (paulis : Pauli[], theta : Double, qubits : Qubit[], rotation : ((Pauli, Qubit) => Unit is Adj + Ctl)) : Unit is Ctl {
        if (Length(paulis) != Length(qubits)) { fail "Arrays 'paulis' and 'qubits' must have the same length"; }
        if (Length(paulis) == 1) {
            rotation(paulis[0], qubits[0]);
        }
        elif (Length(paulis) == 2) {
            within {
                MapPauli(qubits[1], paulis[0], paulis[1]);
            }
            apply {
                if (paulis[0] == PauliX) {
                    IsingXX(theta / 2.0, qubits[0], qubits[1]);
                } elif (paulis[0] == PauliY) {
                    IsingYY(theta / 2.0, qubits[0], qubits[1]);
                } elif (paulis[0] == PauliZ) {
                    IsingZZ(theta / 2.0, qubits[0], qubits[1]);
                } else {
                    fail "Type2 decompositions do not support PauliI as an input to Exp";
                }
            }
        }
        else { // Length(paulis) > 2 
            within {
                for i in 0 .. Length(paulis) - 1 {
                    MapPauli(qubits[i], PauliZ, paulis[i]);
                }
            }
            apply {
                within {
                    SpreadZ(qubits[1], qubits[2 .. Length(qubits) - 1]);
                }
                apply {
                    IsingZZ(theta / 2.0, qubits[0], qubits[1]);
                }
            }
        }
    }

}
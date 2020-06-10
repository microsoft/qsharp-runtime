// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Intrinsic {
    open Microsoft.Quantum.Decompositions.Utilities as Utils;
    open Microsoft.Quantum.Diagnostics;

    @EnableTestingViaName("Test.Decompositions.ExpNoId")
    internal operation ExpNoId(paulis : Pauli[], theta : Double, qubits : Qubit[]) : Unit is Ctl {
        if (Length(paulis) != Length(qubits)) { fail "Arrays 'paulis' and 'qubits' must have the same length"; }
        if (Length(paulis) == 1) {
            R(paulis[0], -2.0 * theta, qubits[0]);
        }
        elif ( Length(paulis) == 2 ) {
            if (paulis[0] != paulis[1] or paulis[0] == PauliI) { fail $"Type 2 Decompositions support only rotation around XX, YY, ZZ given {paulis}"; }
            within {
                MapPauli(qubits[1], paulis[0], paulis[1]);
            }
            apply {
                if (paulis[1] == PauliX) {
                    IsingXX(theta / 2.0, qubits[0], qubits[1]);
                } elif (paulis[1] == PauliY) {
                    IsingYY(theta / 2.0, qubits[0], qubits[1]);
                } elif (paulis[1] == PauliZ) {
                    IsingZZ(theta / 2.0, qubits[0], qubits[1]);
                } else {
                    fail "Type2 decompositions do not support PauliI";
                }
            }
        }
        else { // Length(paulis) > 2 
            within {
                for (i in 0 .. Length(paulis) - 1) {
                    MapPauli(qubits[i], PauliZ, paulis[i]);
                }
            }
            apply {
                within {
                    SpreadZ(qubits[1], qubits[2 .. Length(qubits) - 1]);
                }
                apply {
                    ExpNoId([PauliZ,PauliZ], theta, [qubits[0], qubits[1]]);
                }
            }
        }
    }

    @EnableTestingViaName("Test.Decompositions.ApplyGlobalPhase")
    internal operation ApplyGlobalPhase(theta : Double) : Unit is Ctl + Adj {
        body(...) {}
        controlled(controls, (...)) {
            if (Length(controls) > 0) {
                let qubit = controls[0]; //Microsoft.Quantum.Arrays.Head(controls);
                let rest = controls[1...]; //Microsoft.Quantum.Arrays.Rest(controls);
                // Invoke Controlled R1, which will recursively call back into ApplyGlobalPhase.
                // Each time the controls is one shorter, until it is empty and the recursion stops.
                Controlled R1(rest, (theta, qubit));
            }
        }
    }

    @EnableTestingViaName("Test.Decompositions.TS")
    internal operation TS(target : Qubit) : Unit is Adj + Ctl {
        T(target);
        S(target);
    }

    @EnableTestingViaName("Test.Decompositions.ExpNoIdFrac")
    internal operation ExpNoIdFrac(paulis : Pauli[], numerator : Int, power : Int, qubits : Qubit[]) : Unit is Ctl {
        if (Length(paulis) != Length(qubits)) { fail "Arrays 'paulis' and 'qubits' must have the same length"; }

        let (kModPositive,n) = Utils.ReducedDyadicFractionPeriodic(numerator, power); // k is odd, in the range [1,2*2^n-1] or (k,n) are both 0
        let numeratorD = Microsoft.Quantum.Math.PI() * Microsoft.Quantum.Convert.IntAsDouble(kModPositive);
        let theta = numeratorD * Microsoft.Quantum.Math.PowD(2.0, Microsoft.Quantum.Convert.IntAsDouble(-n));

        if (Length(paulis) == 1 ) {
            RFrac(paulis[0], numerator, power, qubits[0]);
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
                    fail "Type2 decompositions do not support PauliI";
                }
            }
        }
        else { // Length(paulis) > 2 
            within {
                for (i in 0 .. Length(paulis) - 1) {
                    MapPauli(qubits[i], PauliZ, paulis[i]);
                }
            }
            apply {
                within {
                    SpreadZ(qubits[1], qubits[2 .. Length(qubits) - 1]);
                }
                apply {
                    ExpNoId([PauliZ,PauliZ], theta, [qubits[0], qubits[1]]);
                }
            }
        }
    }

}

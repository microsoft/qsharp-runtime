// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Experimental.Decompositions {
    open Microsoft.Quantum.Simulation.Simulators.NativeInterface as Native;
    open Microsoft.Quantum.Simulation.Simulators.IntrinsicInterface as Intrinsic;

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

    internal operation MeasureWithoutPauliI(bases : Pauli[], register : Qubit[]) : Result {
        mutable newBases = [];
        mutable newQubits = [];
        // NB: using Zipped would be nice here, but this is built before
        //     M.Q.Standard...
        for idxBasis in 0..Length(bases) - 1 {
            if bases[idxBasis] != PauliI {
                set newBases += [bases[idxBasis]];
                set newQubits += [register[idxBasis]];
            }
        }

        if Length(newBases) == 0 {
            return Zero;
        } else {
            return Intrinsic.Measure(newBases, newQubits);
        }
    }

    internal operation ApplyGlobalPhase (theta : Double) : Unit is Ctl + Adj {
        body (...) {}
        controlled (controls, (...)) {
            if Length(controls) == 0 {
                // Noop
            }
            elif Length(controls) == 1 {
                Intrinsic.R(PauliZ, theta, controls[0]);
            }
            elif Length(controls) == 2 {
                Controlled Intrinsic.R1([controls[1]], (theta, controls[0]));
            }
            elif Length(controls) == 3 {
                Controlled Intrinsic.R1([controls[1], controls[2]], (theta, controls[0]));
            }
            elif Length(controls) == 4 {
                Controlled Intrinsic.R1([controls[1], controls[2], controls[3]], (theta, controls[0]));
            }
            elif Length(controls) == 5 {
                Controlled Intrinsic.R1([controls[1], controls[2], controls[3], controls[4]], (theta, controls[0]));
            }
            elif Length(controls) == 6 {
                Controlled Intrinsic.R1([controls[1], controls[2], controls[3], controls[4], controls[5]], (theta, controls[0]));
            }
            elif Length(controls) == 7 {
                Controlled Intrinsic.R1([controls[1], controls[2], controls[3], controls[4], controls[5], controls[6]], (theta, controls[0]));
            }
            elif Length(controls) == 8 {
                Controlled Intrinsic.R1([controls[1], controls[2], controls[3], controls[4], controls[5], controls[6], controls[7]], (theta, controls[0]));
            }
            else {
                fail "Too many controls specified to R gate.";
            }
        }
    }

    internal operation CRz(control : Qubit, theta : Double, target : Qubit) : Unit is Adj {
        Intrinsic.Rz(theta / 2.0, target);
        Controlled Intrinsic.X([control], target);
        Intrinsic.Rz(-theta / 2.0, target);
        Controlled Intrinsic.X([control], target);
    }

    internal operation CR1(theta : Double, control : Qubit, target : Qubit) : Unit is Adj {
        Intrinsic.R(PauliZ, theta/2.0, target);
        Intrinsic.R(PauliZ, theta/2.0, control);
        Controlled Intrinsic.X([control], target);
        Intrinsic.R(PauliZ, -theta/2.0, target);
        Controlled Intrinsic.X([control], target);
    }

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

    internal operation SpreadZ (from : Qubit, to : Qubit[]) : Unit is Adj {
        if (Length(to) > 0) {
            Controlled Intrinsic.X([to[0]], from);
            if (Length(to) > 1) {
                let half = Length(to) / 2;
                SpreadZ(to[0], to[half + 1 .. Length(to) - 1]);
                SpreadZ(from, to[1 .. half]);
            }
        }
    }

    internal function RemovePauliI (paulis : Pauli[], qubits : Qubit[]) : (Pauli[], Qubit[]) {
        let indices = IndicesOfNonIdentity(paulis);
        let newPaulis = Subarray(indices, paulis);
        let newQubits = Subarray(indices, qubits);
        return (newPaulis, newQubits);
    }

    internal function Subarray<'T> (indices : Int[], array : 'T[]) : 'T[] {
        let nSliced = Length(indices);
        mutable sliced = new 'T[nSliced];

        for idx in 0 .. nSliced - 1 {
            set sliced w/= idx <- array[indices[idx]];
        }

        return sliced;
    }

    internal function IndicesOfNonIdentity (paulis : Pauli[]) : Int[] {
        mutable nonIdPauliCount = 0;

        for i in 0 .. Length(paulis) - 1 {
            if paulis[i] != PauliI {
                set nonIdPauliCount += 1;
            }
        }

        mutable indices = [PauliI, size = nonIdPauliCount];
        mutable index = 0;

        for i in 0 .. Length(paulis) - 1 {
            if paulis[i] != PauliI {
                set indices w/= index <- i;
                set index += 1;
            }
        }

        return indices;
    }

}

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
            if (Length(controls) > 0) {
                let qubit = controls[0];
                let rest = controls[1...];
                // Invoke Controlled R1, which will recursively call back into ApplyGlobalPhase.
                // Each time the controls is one shorter, until it is empty and the recursion stops.
                Controlled Intrinsic.R1(rest, (theta, qubit));
            }
        }
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
        
        mutable indices = new Int[nonIdPauliCount];
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

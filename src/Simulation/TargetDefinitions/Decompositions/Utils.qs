// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Intrinsic {
    open Microsoft.Quantum.Measurement;

    internal operation SpreadZ (from : Qubit, to : Qubit[]) : Unit is Adj {
        if (Length(to) > 0) {
            CNOT(to[0], from);
            if (Length(to) > 1) {
                let half = Length(to) / 2;
                SpreadZ(to[0], to[half + 1 .. Length(to) - 1]);
                SpreadZ(from, to[1 .. half]);
            }
        }
    }

    internal operation MapPauli (qubit : Qubit, from : Pauli, to : Pauli) : Unit is Adj {
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

    internal operation EntangleForJointMeasure(basis : Pauli, aux : Qubit, qubit : Qubit) : Unit {
        if basis == PauliX {
            Controlled X([aux], qubit);
        }
        elif basis == PauliZ {
            Controlled Z([aux], qubit);
        }
        elif basis == PauliY {
            Controlled Y([aux], qubit);
        }
    }

    internal operation CollectControls(ctls : Qubit[], aux : Qubit[]) : Unit is Adj {
        for i in 0..2..(Length(ctls) - 2) {
            PhaseCCX(ctls[i], ctls[i + 1], aux[i / 2]);
        }
        for i in 0..((Length(ctls) / 2) - 2) {
            PhaseCCX(aux[i * 2], aux[(i * 2) + 1], aux[i + Length(ctls) / 2]);
        }
    }

    internal operation AdjustForSingleControl(ctls : Qubit[], aux : Qubit[]) : Unit is Adj {
        if Length(ctls) % 2 != 0 {
            PhaseCCX(ctls[Length(ctls) - 1], aux[Length(ctls) - 3], aux[Length(ctls) - 2]);
        }
    }

    internal operation PhaseCCX (control1 : Qubit, control2 : Qubit, target : Qubit) : Unit is Adj {
        // https://arxiv.org/pdf/1210.0974.pdf#page=2
        H(target);
        CNOT(target,control1);
        CNOT(control1,control2);
        T(control2);
        Adjoint T(control1);
        T(target);
        CNOT(target,control1);
        CNOT(control1,control2);
        Adjoint T(control2);
        CNOT(target,control2);
        H(target);
    }

    internal operation CCZ (control1 : Qubit, control2 : Qubit, target : Qubit) : Unit is Adj {
        // [Page 15 of arXiv:1206.0758v3](https://arxiv.org/pdf/1206.0758v3.pdf#page=15)
        Adjoint T(control1);
        Adjoint T(control2);
        CNOT(target, control1);
        T(control1);
        CNOT(control2, target);
        CNOT(control2, control1);
        T(target);
        Adjoint T(control1);
        CNOT(control2, target);
        CNOT(target, control1);
        Adjoint T(target);
        T(control1);
        CNOT(control2, control1);
    }

    internal function ReducedDyadicFraction (numerator : Int, denominatorPowerOfTwo : Int) : (Int, Int) {
        if (numerator == 0) { return (0,0); }
        mutable num = numerator;
        mutable denPow = denominatorPowerOfTwo;
        while(num % 2 == 0) {
            set num /= 2;
            set denPow += 1;
        }
        return (num,denPow);
    }

    internal function ReducedDyadicFractionPeriodic (numerator : Int, denominatorPowerOfTwo : Int) : (Int, Int) {
        let (k,n) = ReducedDyadicFraction(numerator,denominatorPowerOfTwo); // k is odd, or (k,n) are both 0
        let period = 2*2^n; // \pi k / 2^n is 2\pi periodic, therefore k is 2 * 2^n periodic
        let kMod = k % period; // if k was negative, we get kMod in a range [-period + 1, 0]
        let kModPositive = kMod >= 0 ? kMod | kMod + period; // kModPositive is in the range [0, period - 1]
        return (kModPositive, n);
    }

    // TODO(swernli): Consider removing this in favor of pulling Microsoft.Quantum.Arrays.Subarray
    // into the runtime.
    internal function Subarray<'T> (indices : Int[], array : 'T[]) : 'T[] {
        let nSliced = Length(indices);
        mutable sliced = new 'T[nSliced];

        for idx in 0 .. nSliced - 1 {
            set sliced w/= idx <- array[indices[idx]];
        }

        return sliced;
    }

    internal function IndicesOfNonIdentity (paulies : Pauli[]) : Int[] {
        mutable nonIdPauliCount = 0;

        for i in 0 .. Length(paulies) - 1 {
            if (paulies[i] != PauliI) { set nonIdPauliCount += 1; }
        }
        
        mutable indices = new Int[nonIdPauliCount];
        mutable index = 0;
        
        for i in 0 .. Length(paulies) - 1 {
            if (paulies[i] != PauliI) {
                set indices w/= index <- i;
                set index = index + 1;
            }
        }
        
        return indices;
    }

    internal function RemovePauliI (paulis : Pauli[], qubits : Qubit[]) : (Pauli[], Qubit[]) {
        let indices = IndicesOfNonIdentity(paulis);
        let newPaulis = Subarray(indices, paulis);
        let newQubits = Subarray(indices, qubits);
        return (newPaulis, newQubits);
    }

}
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

    internal operation JointMeasure(bases : Pauli[], qubits : Qubit[]) : Result {
        if Length(bases) == 0 {
            return Zero;
        }
        elif Length(bases) == 1 {
            // This case should never get used in practice, and would only be hit if there was
            // a bug in the decompositions that rely on this operation.
            fail "Length 1 case should be handled by callers.";
        }
        elif Length(bases) == 2 {
            use q = Qubit();
            within {
                H(q);
            }
            apply {
                EntangleForJointMeasure(bases[0], q, qubits[0]);
                EntangleForJointMeasure(bases[1], q, qubits[1]);
            }
            return MResetZ(q);
        }
        elif Length(bases) == 3 {
            use q = Qubit();
            within {
                H(q);
            }
            apply {
                EntangleForJointMeasure(bases[0], q, qubits[0]);
                EntangleForJointMeasure(bases[1], q, qubits[1]);
                EntangleForJointMeasure(bases[2], q, qubits[2]);
            }
            return MResetZ(q);
        }
        elif Length(bases) == 4 {
            use q = Qubit();
            within {
                H(q);
            }
            apply {
                EntangleForJointMeasure(bases[0], q, qubits[0]);
                EntangleForJointMeasure(bases[1], q, qubits[1]);
                EntangleForJointMeasure(bases[2], q, qubits[2]);
                EntangleForJointMeasure(bases[3], q, qubits[3]);
            }
            return MResetZ(q);
        }
        elif Length(bases) == 5 {
            use q = Qubit();
            within {
                H(q);
            }
            apply {
                EntangleForJointMeasure(bases[0], q, qubits[0]);
                EntangleForJointMeasure(bases[1], q, qubits[1]);
                EntangleForJointMeasure(bases[2], q, qubits[2]);
                EntangleForJointMeasure(bases[3], q, qubits[3]);
                EntangleForJointMeasure(bases[4], q, qubits[4]);
            }
            return MResetZ(q);
        }
        elif Length(bases) == 6 {
            use q = Qubit();
            within {
                H(q);
            }
            apply {
                EntangleForJointMeasure(bases[0], q, qubits[0]);
                EntangleForJointMeasure(bases[1], q, qubits[1]);
                EntangleForJointMeasure(bases[2], q, qubits[2]);
                EntangleForJointMeasure(bases[3], q, qubits[3]);
                EntangleForJointMeasure(bases[4], q, qubits[4]);
                EntangleForJointMeasure(bases[5], q, qubits[5]);
            }
            return MResetZ(q);
        }
        elif Length(bases) == 7 {
            use q = Qubit();
            within {
                H(q);
            }
            apply {
                EntangleForJointMeasure(bases[0], q, qubits[0]);
                EntangleForJointMeasure(bases[1], q, qubits[1]);
                EntangleForJointMeasure(bases[2], q, qubits[2]);
                EntangleForJointMeasure(bases[3], q, qubits[3]);
                EntangleForJointMeasure(bases[4], q, qubits[4]);
                EntangleForJointMeasure(bases[5], q, qubits[5]);
                EntangleForJointMeasure(bases[6], q, qubits[6]);
            }
            return MResetZ(q);
        }
        elif Length(bases) == 8 {
            use q = Qubit();
            within {
                H(q);
            }
            apply {
                EntangleForJointMeasure(bases[0], q, qubits[0]);
                EntangleForJointMeasure(bases[1], q, qubits[1]);
                EntangleForJointMeasure(bases[2], q, qubits[2]);
                EntangleForJointMeasure(bases[3], q, qubits[3]);
                EntangleForJointMeasure(bases[4], q, qubits[4]);
                EntangleForJointMeasure(bases[5], q, qubits[5]);
                EntangleForJointMeasure(bases[6], q, qubits[6]);
                EntangleForJointMeasure(bases[7], q, qubits[7]);
            }
            return MResetZ(q);
        }
        else {
            fail "Too many qubits specified in call to Measure.";
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

    /// Given a multiply-controlled operation that requires k controls 
    /// applies it using ceiling(k/2) controls and using floor(k/2) temporary qubits
    internal operation ApplyWithLessControlsA<'T> (op : ((Qubit[],'T) => Unit is Adj), (controls : Qubit[], arg : 'T)) : Unit is Adj {
        let numControls = Length(controls);
        let numControlPairs = numControls / 2;
        use temps = Qubit[numControlPairs] {
            within {
                for numPair in 0 .. numControlPairs - 1 { // constant depth
                    PhaseCCX(controls[2*numPair], controls[2*numPair + 1], temps[numPair]);
                }
            }
            apply {
                let newControls = numControls % 2 == 0 ? temps | temps + [controls[numControls - 1]];
                op(newControls, arg);
            }
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
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Intrinsic {

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

    internal operation ApplyGlobalPhase (theta : Double) : Unit is Ctl + Adj {
        body (...) {}
        controlled (controls, (...)) {
            if (Length(controls) > 0) {
                let qubit = controls[0];
                let rest = controls[1...];
                // Invoke Controlled R1, which will recursively call back into ApplyGlobalPhase.
                // Each time the controls is one shorter, until it is empty and the recursion stops.
                Controlled R1(rest, (theta, qubit));
            }
        }
    }

    internal operation ApplyGlobalPhaseFracWithR1Frac (numerator : Int, power : Int) : Unit is Adj + Ctl {
        body (...) {}
        controlled (ctrls, ...) {
            let numControls =  Length(ctrls);
            if (numControls > 0 ) {
                // Invoke Controlled R1Frac, which will recursively call back into ApplyGlobalPhase.
                // Each time the controls is one shorter, until it is empty and the recursion stops.
                Controlled R1Frac(ctrls[1 .. numControls - 1], (numerator, power, ctrls[0]));
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
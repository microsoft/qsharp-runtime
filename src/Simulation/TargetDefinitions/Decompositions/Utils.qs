// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Intrinsic {
    open Microsoft.Quantum.Diagnostics;

    @EnableTestingViaName("Test.TargetDefinitions.ExpNoIdUtil")
    internal operation ExpNoIdUtil(paulis : Pauli[], theta : Double, qubits : Qubit[], rotation : ((Pauli, Qubit) => Unit is Adj + Ctl)) : Unit is Ctl {
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
                for (i in 0 .. Length(paulis) - 1) {
                    MapPauli(qubits[i], PauliZ, paulis[i]);
                }
            }
            apply {
                within {
                    SpreadZ(qubits[1], qubits[2 .. Length(qubits) - 1]);
                }
                apply {
                    ExpNoIdUtil([PauliZ,PauliZ], theta, [qubits[0], qubits[1]], rotation);
                }
            }
        }
    }

    @EnableTestingViaName("Test.TargetDefinitions.SpreadZ")
    internal operation SpreadZ(from : Qubit, to : Qubit[]) : Unit is Adj {
        if (Length(to) > 0) {
            CNOT(to[0], from);
            if (Length(to) > 1) {
                let half = Length(to) / 2;
                SpreadZ(to[0], to[half + 1 .. Length(to) - 1]);
                SpreadZ(from, to[1 .. half]);
            }
        }
    }

    @EnableTestingViaName("Test.TargetDefinitions.ApplyGlobalPhase")
    internal operation ApplyGlobalPhase(theta : Double) : Unit is Ctl + Adj {
        body(...) {}
        controlled(controls, (...)) {
            if (Length(controls) > 0) {
                let qubit = controls[0];
                let rest = controls[1...];
                // Invoke Controlled R1, which will recursively call back into ApplyGlobalPhase.
                // Each time the controls is one shorter, until it is empty and the recursion stops.
                Controlled R1(rest, (theta, qubit));
            }
        }
    }

    @EnableTestingViaName("Test.TargetDefinitions.ApplyGlobalPhaseFracWithR1Frac")
    internal operation ApplyGlobalPhaseFracWithR1Frac(numerator : Int, power : Int) : Unit is Adj + Ctl {
        body(...) {}
        controlled(ctrls, ... ) {
            let numControls =  Length(ctrls);
            if (numControls > 0 ) {
                // Invoke Controlled R1Frac, which will recursively call back into ApplyGlobalPhase.
                // Each time the controls is one shorter, until it is empty and the recursion stops.
                Controlled R1Frac(ctrls[1 .. numControls - 1], (numerator, power, ctrls[0]));
            }
        }
    }

    @EnableTestingViaName("Test.TargetDefinitions.MapPauli")
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

    @EnableTestingViaName("Test.TargetDefinitions.ReducedDyadicFraction")
    internal function ReducedDyadicFraction(numerator : Int, denominatorPowerOfTwo : Int) : (Int,Int) {
        if (numerator == 0) { return (0,0); }
        mutable num = numerator;
        mutable denPow = denominatorPowerOfTwo;
        while(num % 2 == 0) {
            set num /= 2;
            set denPow += 1;
        }
        return (num,denPow);
    }

    @EnableTestingViaName("Test.TargetDefinitions.ReducedDyadicFractionPeriodic")
    internal function ReducedDyadicFractionPeriodic(numerator : Int, denominatorPowerOfTwo : Int) : (Int,Int) {
        let (k,n) = ReducedDyadicFraction(numerator,denominatorPowerOfTwo); // k is odd, or (k,n) are both 0
        let period = 2*2^n; // \pi k / 2^n is 2\pi periodic, therefore k is 2 * 2^n periodic
        let kMod = k % period; // if k was negative, we get kMod in a range [-period + 1, 0]
        let kModPositive = kMod >= 0 ? kMod | kMod + period; // kModPositive is in the range [0, period - 1]
        return (kModPositive, n);
    }

    @EnableTestingViaName("Test.TargetDefinitions.ArrayFromIndicesP")
    internal function ArrayFromIndiciesP(values : Pauli[], indicies : Int[]) : Pauli[] {
        mutable arr = new Pauli[Length(indicies)];
        for (i in 0 .. Length(indicies) - 1) {
            set arr w/= i <- values[indicies[i]];
        }
        return arr;
    }

    @EnableTestingViaName("Test.TargetDefinitions.ArrayFromIndicesQ")
    internal function ArrayFromIndiciesQ(values : Qubit[], indicies : Int[]) : Qubit[] {
        mutable arr = new Qubit[Length(indicies)];
        for (i in 0 .. Length(indicies) - 1) {
            set arr w/= i <- values[indicies[i]];
        }
        return arr;
    }

    @EnableTestingViaName("Test.TargetDefinitions.IndicesOfNonIdentity")
    internal function IndicesOfNonIdentity(paulies : Pauli[]) : Int[] {
        mutable nonIdPauliCount = 0;

        for (i in 0 .. Length(paulies) - 1) {
            if (paulies[i] != PauliI) { set nonIdPauliCount += 1; }
        }
        
        mutable indices = new Int[nonIdPauliCount];
        mutable index = 0;
        
        for (i in 0 .. Length(paulies) - 1) {
            if (paulies[i] != PauliI) {
                set indices w/= index <- i;
                set index = index + 1;
            }
        }
        
        return indices;
    }

    @EnableTestingViaName("Test.TargetDefinitions.RemovePauliI")
    internal function RemovePauliI(paulis : Pauli[], qubits : Qubit[]) : (Pauli[], Qubit[]) {
        let indices = IndicesOfNonIdentity(paulis);
        let newPaulis = ArrayFromIndiciesP(paulis, indices);
        let newQubits = ArrayFromIndiciesQ(qubits, indices);
        return (newPaulis, newQubits);
    }

}
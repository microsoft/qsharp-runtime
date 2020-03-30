// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

/// Decompositions of some Q# operations into more primitive ones
/// that can be directly executed on various target hardware.
namespace Microsoft.Quantum.Targeting.Decompositions {
    open Microsoft.Quantum.Intrinsic;

    /// # Summary 
    /// Calls "fail message" when the first argument is True
    internal function FailIf(failIfTrue : Bool, message : String) : Unit {
        if (failIfTrue) {
            fail message;
        }
    }

    /// # Summary
    /// Finds a first Pauli not equal to PauliI in the array
    internal function FirstIndexOfNonId(array : Pauli[]) : Int {
        for (i in 0 .. Length(array) - 1) {
            if( array[i] != PauliI ) {
                return i;
            }
        }
        return -1;
    }

    /// # Summary
    /// Applies a Clifford unitary that maps by conjugation Pauli Z
    /// to Pauli given by 'basis' argument. The unitary is applied to the qubit given by 'target' argument 
    internal operation PauliZFlip(basis : Pauli, target : Qubit) : Unit is Adj+Ctl {

        FailIf(basis == PauliI, $"PauliZ cannot be mapped to PauliI using conjugation by Clifford");

        if (basis == PauliX) {
            H(target);
        }
        elif (basis == PauliY) {
            H(target);
            S(target);
            H(target);
        }
        else {
            FailIf(basis != PauliZ, $"PauliZ must be the only remaining case");
        }
    }

    /////////////////////////////////////////////////////////////////////////////////////////////////////////

    internal operation ExpHelper(target : Qubit, paulis : Pauli[], qubits : Qubit[]) : Unit is Adj+Ctl {
        for (i in 0 .. Length(paulis) - 1) {
            if (paulis[i] != PauliI) {
                PauliZFlip(paulis[i], qubits[i]);
                CNOT(qubits[i],target);
            }
        }
    }

    /// # Warning 
    /// Very inefficient implementation in terms of depth
    internal operation Exp(paulis : Pauli[], theta : Double, qubits : Qubit[]) : Unit is Adj + Ctl {
        FailIf(Length(paulis) == 0, "");
        FailIf(Length(paulis) != Length(qubits), "");

        let index = FirstIndexOfNonId(paulis);
        if (index != -1) {
            PauliZFlip(paulis[index], qubits[index]);
            ExpHelper(qubits[index], paulis[index + 1 .. Length(paulis) - 1], qubits[index + 1 .. Length(qubits) - 1]);
            R(PauliZ, -2.0 * theta, qubits[index]);
            Adjoint ExpHelper(qubits[index], paulis[index + 1 .. Length(paulis) - 1], qubits[index + 1 .. Length(qubits) - 1]);
            Adjoint PauliZFlip(paulis[index], qubits[index]);
        }
        else
        {
            R(PauliI, -2.0 * theta, qubits[0]);
        }
    }

    internal operation ExpFrac(paulis : Pauli[], numerator : Int, power : Int, qubits : Qubit[]) : Unit {
        FailIf(Length(paulis) == 0, "");
        FailIf(Length(paulis) != Length(qubits), "");

        let index = FirstIndexOfNonId(paulis);
        if (index != -1) {
            PauliZFlip(paulis[index], qubits[index]);
            ExpHelper(qubits[index], paulis[index + 1 .. Length(paulis) - 1], qubits[index + 1 .. Length(qubits) - 1]);
            RFrac(PauliZ, numerator, power, qubits[index]);
            Adjoint ExpHelper(qubits[index], paulis[index + 1 .. Length(paulis) - 1], qubits[index + 1 .. Length(qubits) - 1]);
            Adjoint PauliZFlip(paulis[index], qubits[index]);
        }
        else
        {
            RFrac(PauliI, numerator, power, qubits[0]);
        }
    }

    /// # Warning 
    /// Very inefficient implementation in terms of depth
    internal operation Measure(paulis : Pauli[], qubits : Qubit[]) : Result {
        FailIf(Length(paulis) == 0, "" );
        FailIf(Length(paulis) != Length(qubits), "");
        mutable res = Zero;

        let index = FirstIndexOfNonId(paulis);
        if (index != -1) {
            PauliZFlip(paulis[index], qubits[index]);
            ExpHelper(qubits[index], paulis[index+1 .. Length(paulis)-1], qubits[index+1 .. Length(qubits)-1]);
            set res = M(qubits[index]);
            Adjoint ExpHelper(qubits[index], paulis[index+1 .. Length(paulis)-1], qubits[index+1 .. Length(qubits)-1]);
            Adjoint PauliZFlip(paulis[index], qubits[index]);
        }
        return res;
    }
    
    internal operation MResetZ(target : Qubit) : Result {
        let r = M(target);
        Reset(target);

        return r;
    }
}

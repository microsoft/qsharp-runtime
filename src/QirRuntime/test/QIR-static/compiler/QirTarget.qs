// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Intrinsic {

    open Microsoft.Quantum.Targeting;

    operation X(qb : Qubit) : Unit
    is Adj + Ctl {
        body intrinsic;
        adjoint self;
    }

    operation Y(qb : Qubit) : Unit
    is Adj + Ctl {
        body intrinsic;
        adjoint self;
    }

    operation Z(qb : Qubit) : Unit
    is Adj + Ctl {
        body intrinsic;
        adjoint self;
    }

    operation H(qb : Qubit) : Unit
    is Adj + Ctl {
        body intrinsic;
        adjoint self;
    }

    operation S(qb : Qubit) : Unit
    is Adj + Ctl {
        body intrinsic;
    }

    operation T(qb : Qubit) : Unit
    is Adj + Ctl {
        body intrinsic;
    }

    operation R (pauli : Pauli, theta : Double, qubit : Qubit) : Unit
    is Adj + Ctl
    {
        body intrinsic;
    }

    operation Exp (paulis : Pauli[], theta : Double, qubits : Qubit[]) : Unit
    is Adj + Ctl
    {
        body intrinsic;
    }

    operation Measure(bases : Pauli[], qubits : Qubit[]) : Result {
        body intrinsic;
    }

    operation M(qb : Qubit) : Result {
        body (...) {
            return Measure([PauliZ], [qb]);
        }
    }
}

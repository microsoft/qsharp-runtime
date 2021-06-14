// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

// This namespace contains those intrinsics supported by the experimental
// simulators native interface (NativeInterface.cs).

namespace Microsoft.Quantum.Experimental.Native {

    operation H(target : Qubit) : Unit is Adj {
        body intrinsic;
        adjoint self;
    }

    operation X(target : Qubit) : Unit is Adj {
        body intrinsic;
        adjoint self;
    }

    operation Y(target : Qubit) : Unit is Adj {
        body intrinsic;
        adjoint self;
    }

    operation Z(target : Qubit) : Unit is Adj {
        body intrinsic;
        adjoint self;
    }

    operation S(target : Qubit) : Unit is Adj {
        body intrinsic;
        adjoint intrinsic;
    }

    operation T(target : Qubit) : Unit is Adj {
        body intrinsic;
        adjoint intrinsic;
    }

    operation CNOT(control : Qubit, target : Qubit) : Unit is Adj {
        body intrinsic;
        adjoint self;
    }

    operation M(target : Qubit) : Result {
        body intrinsic;
    }

}
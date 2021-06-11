// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

// This namespace contains those intrinsics supported by the experimental
// simulators native interface (NativeInterface.cs).

namespace Microsoft.Quantum.Experimental.Native {

    internal operation H(target : Qubit) : Unit {
        body intrinsic;
        adjoint self;
    }

    internal operation X(target : Qubit) : Unit {
        body intrinsic;
        adjoint self;
    }

    internal operation Y(target : Qubit) : Unit {
        body intrinsic;
        adjoint self;
    }

    internal operation Z(target : Qubit) : Unit {
        body intrinsic;
        adjoint self;
    }

    internal operation S(target : Qubit) : Unit {
        body intrinsic;
        adjoint intrinsic;
    }

    internal operation T(target : Qubit) : Unit {
        body intrinsic;
        adjoint intrinsic;
    }

    internal operation CNOT(control : Qubit, target : Qubit) : Unit {
        body intrinsic;
        adjoint self;
    }

    internal operation M(target : Qubit) : Result {
        body intrinsic;
    }

}
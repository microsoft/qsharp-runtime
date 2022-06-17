// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

// This namespace contains those intrinsics supported by the experimental
// simulators native interface (NativeInterface.cs).

namespace Microsoft.Quantum.Simulation.Simulators.NativeInterface {

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

    operation Rx(theta : Double, target : Qubit) : Unit {
        body intrinsic;
    }

    operation Ry(theta : Double, target : Qubit) : Unit {
        body intrinsic;
    }

    operation Rz(theta : Double, target : Qubit) : Unit {
        body intrinsic;
    }

    operation M(target : Qubit) : Result {
        body intrinsic;
    }

}
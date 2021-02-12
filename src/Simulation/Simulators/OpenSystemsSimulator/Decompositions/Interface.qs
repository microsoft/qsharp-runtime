// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Experimental {
    open Microsoft.Quantum.Intrinsic;

    operation ApplyUncontrolledH(target : Qubit) : Unit is Adj {
        body intrinsic;
        adjoint self;
    }

    operation ApplySinglyControlledX(control : Qubit, target : Qubit) : Unit is Adj {
        body intrinsic;
        adjoint self;
    }

}


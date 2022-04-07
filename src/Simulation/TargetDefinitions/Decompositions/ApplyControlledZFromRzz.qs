// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Intrinsic {

    internal operation ApplyControlledZ(control : Qubit, target : Qubit) : Unit is Adj {
        body (...) {
            // NB: CZ is symmetic under swap, so we need for the below decomposition to
            //     treat control and target identically.
            ApplyUncontrolledZZ(PI(), control, target);
            ApplyUncontrolledRz(-PI() / 2.0, control);
            ApplyUncontrolledRz(-PI() / 2.0, target);
        }
        adjoint self;
    }
}

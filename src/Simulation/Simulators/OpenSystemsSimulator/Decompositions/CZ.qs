// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Experimental {

    internal operation ApplyCZUsingCNOT(control : Qubit, target : Qubit) : Unit {
        within {
            ApplyUncontrolledH(target);
        } apply {
            ApplySinglyControlledX(control, target);
        }
    }
}

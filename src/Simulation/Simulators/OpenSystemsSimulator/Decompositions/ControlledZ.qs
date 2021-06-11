// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Experimental.Decompositions {

    internal operation ApplyCZUsingCNOT(control : Qubit, target : Qubit) : Unit {
        within {
            Microsoft.Quantum.Intrinsic.H(target);
        } apply {
            Controlled Microsoft.Quantum.Intrinsic.X([control], target);
        }
    }

}

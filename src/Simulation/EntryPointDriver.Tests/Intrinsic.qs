// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Intrinsic {
    operation H (q : Qubit) : Unit {
        body intrinsic;
        adjoint intrinsic;
        controlled intrinsic;
        controlled adjoint intrinsic;
    }
    
    operation X (q : Qubit) : Unit {
        body intrinsic;
        adjoint intrinsic;
        controlled intrinsic;
        controlled adjoint intrinsic;
    }
    
    operation M (q : Qubit) : Result {
        body intrinsic;
    }
}

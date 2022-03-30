// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Intrinsic {
    open Microsoft.Quantum.Targeting;

    @TargetInstruction("zz__body")
    operation ApplyUncontrolledZZ (theta : Double, qubit1 : Qubit, qubit2 : Qubit) : Unit {
        body intrinsic;
    }
}
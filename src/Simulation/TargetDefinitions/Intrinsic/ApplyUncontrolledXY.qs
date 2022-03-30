// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Intrinsic {
    open Microsoft.Quantum.Targeting;

    @TargetInstruction("xy__body")
    operation ApplyUncontrolledXY (qubit1 : Qubit, qubit2 : Qubit) : Unit is Adj {
        body intrinsic;
        adjoint self;
    }
}
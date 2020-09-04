// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Intrinsic {
    open Microsoft.Quantum.Diagnostics;

    /// Helper for native Uncontrolled Rx.
    @EnableTestingViaName("Test.TargetDefinitions.ApplyUncontrolledRx")
    internal operation ApplyUncontrolledRx (theta : Double, qubit : Qubit) : Unit is Adj {
        body intrinsic;
        adjoint self;
    }
}
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Intrinsic {
    open Microsoft.Quantum.Diagnostics;

    /// Helper for native Uncontrolled Rz.
    @EnableTestingViaName("Test.TargetDefinitions.ApplyUncontrolledRz")
    internal operation ApplyUncontrolledRz (theta : Double, qubit : Qubit) : Unit is Adj {
        body intrinsic;
        adjoint self;
    }
}
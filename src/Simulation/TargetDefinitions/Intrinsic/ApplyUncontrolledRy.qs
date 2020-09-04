// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Intrinsic {
    open Microsoft.Quantum.Diagnostics;

    /// Helper for native Uncontrolled Ry.
    @EnableTestingViaName("Test.TargetDefinitions.ApplyUncontrolledRy")
    internal operation ApplyUncontrolledRy (theta : Double, qubit : Qubit) : Unit is Adj {
        body intrinsic;
        adjoint self;
    }
}
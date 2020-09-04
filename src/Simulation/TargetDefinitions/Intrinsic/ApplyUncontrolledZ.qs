// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Intrinsic {
    open Microsoft.Quantum.Diagnostics;

    /// Helper for native Uncontrolled Z.
    @EnableTestingViaName("Test.TargetDefinitions.ApplyUncontrolledZ")
    internal operation ApplyUncontrolledZ (qubit : Qubit) : Unit is Adj {
        body intrinsic;
        adjoint self;
    }
}
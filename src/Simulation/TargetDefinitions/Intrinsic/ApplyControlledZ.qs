// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Intrinsic {
    open Microsoft.Quantum.Diagnostics;

    /// Helper for native Controlled Z.
    @EnableTestingViaName("Test.TargetDefinitions.ApplyControlledZ")
    internal operation ApplyControlledZ (control : Qubit, target : Qubit) : Unit is Adj {
        body intrinsic;
        adjoint self;
    }
}
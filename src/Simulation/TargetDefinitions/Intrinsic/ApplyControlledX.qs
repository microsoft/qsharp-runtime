// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Intrinsic {
    open Microsoft.Quantum.Diagnostics;

    /// Helper for native Controlled X.
    @EnableTestingViaName("Test.TargetDefinitions.ApplyControlledX")
    internal operation ApplyControlledX (control : Qubit, target : Qubit) : Unit is Adj {
        body intrinsic;
        adjoint self;
    }
}
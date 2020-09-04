// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Intrinsic {
    open Microsoft.Quantum.Diagnostics;

    /// Helper for native Uncontrolled H.
    @EnableTestingViaName("Test.TargetDefinitions.ApplyUncontrolledH")
    internal operation ApplyUncontrolledH (qubit : Qubit) : Unit is Adj {
        body intrinsic;
        adjoint self;
    }
}
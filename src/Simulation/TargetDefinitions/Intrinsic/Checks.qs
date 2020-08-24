// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Intrinsic {
    open Microsoft.Quantum.Diagnostics;

    @EnableTestingViaName("Test.TargetDefinitions.CheckQubitUniqueness")
    operation CheckQubitUniqueness (qubits : Qubit[]) : Unit is Adj + Ctl{
        body intrinsic;
        adjoint self;
    }

    @EnableTestingViaName("Test.TargetDefinitions.RotationAngleValidation")
    function RotationAngleValidation (angle : Double) : Unit {
        body intrinsic;
    }

}
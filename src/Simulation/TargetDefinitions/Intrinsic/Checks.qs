// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Intrinsic {
    open Microsoft.Quantum.Diagnostics;

    /// # Summary
    /// Checks that all qubits operated on are unique.
    ///
    /// # Description
    /// Will fail if any qubits are repeated or null.
    ///
    /// # Input
    /// ## qubits
    /// The array of qubits to verify for uniqueness. In the controlled variant
    /// the full list of qubits among targets and controls are verified to be unique.
    @EnableTestingViaName("Test.TargetDefinitions.CheckQubitUniqueness")
    operation CheckQubitUniqueness (qubits : Qubit[]) : Unit is Adj + Ctl{
        body intrinsic;
        adjoint self;
    }


    /// # Summary
    /// Validates that the given angle is a Double that can be used for rotation.
    ///
    /// # Description
    /// Validates that the value of the Double representing a rotation angle is neither infinite nor NaN.
    ///
    /// # Input
    /// ## angle
    /// The Double to validate.
    @EnableTestingViaName("Test.TargetDefinitions.RotationAngleValidation")
    function RotationAngleValidation (angle : Double) : Unit {
        body intrinsic;
    }

}
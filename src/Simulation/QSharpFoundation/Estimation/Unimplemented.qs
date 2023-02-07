// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

// Functionality needed to account for costs of an operation that is not implemented.
// Costs estimated separately and passed to the `UnimplementedOperation` become
// incorporated into the overall program costs. This functionality can only be used
// by the resources estimator target.

namespace Microsoft.Quantum.Estimation {

    /// # Summary
    /// Indicates that the second item in a tuple passed to the `UnimplementedOperation`
    /// is the number of the T gates.
    function TCount() : Int {
        return 1;
    }

    /// # Summary
    /// Indicates that the second item in a tuple passed to the `UnimplementedOperation`
    /// is the count of rotations.
    function RotationCount() : Int {
        return 2;
    }

    /// # Summary
    /// Indicates that the second item in a tuple passed to the `UnimplementedOperation`
    /// is the rotation depth.
    function RotationDepth() : Int {
        return 3;
    }

    /// # Summary
    /// Indicates that the second item in a tuple passed to the `UnimplementedOperation`
    /// is the number of CCZ gates.
    function CczCount() : Int {
        return 4;
    }

    /// # Summary
    /// Indicates that the second item in a tuple passed to the `UnimplementedOperation`
    /// is the number of measurements.
    function MeasurementCount() : Int {
        return 5;
    }

    /// # Summary
    /// Account for costs of an unimplemented operation which are estimated separately.
    ///
    /// # Input
    /// ## arguments
    /// Operation takes these qubits as its arguments.
    /// ## auxQubitCount
    /// Operation requires this many auxilliary qubits.
    /// ## cost
    /// Array of tuples containing costs of the operation. For example, if the operation uses there
    /// T gates, pass tuple (TCount(), 3) as one of the array elements.
    operation UnimplementedOperation(arguments: Qubit[], auxQubitCount: Int, cost: (Int, Int)[]): Unit is Adj {
        body intrinsic;
        adjoint self;
    }

}

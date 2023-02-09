// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

// Functionality needed to account for costs of an operation that is not implemented.
// Costs estimated separately and passed to the `UnimplementedOperation` become
// incorporated into the overall program costs. This functionality is only available
// when using resources estimator execution target. `UnimplementedOperation' is not
// defined for other execution targets.

namespace Microsoft.Quantum.ResourcesEstimation {

    /// # Summary
    /// Indicates that the second item in a tuple passed to the `UnimplementedOperation`
    /// is the number of the T gates.
    function TCountKey() : Int {
        return 1;
    }

    /// # Summary
    /// Indicates that the second item in a tuple passed to the `UnimplementedOperation`
    /// is the count of rotations.
    function RotationCountKey() : Int {
        return 2;
    }

    /// # Summary
    /// Indicates that the second item in a tuple passed to the `UnimplementedOperation`
    /// is the rotation depth.
    function RotationDepthKey() : Int {
        return 3;
    }

    /// # Summary
    /// Indicates that the second item in a tuple passed to the `UnimplementedOperation`
    /// is the number of CCZ gates.
    function CczCountKey() : Int {
        return 4;
    }

    /// # Summary
    /// Indicates that the second item in a tuple passed to the `UnimplementedOperation`
    /// is the number of measurements.
    function MeasurementCountKey() : Int {
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
    /// T gates, pass tuple (TCountKey(), 3) as one of the array elements.
    operation UnimplementedOperation(arguments: Qubit[], auxQubitCount: Int, cost: (Int, Int)[]): Unit is Adj {
        body intrinsic;
        adjoint self;
    }

}

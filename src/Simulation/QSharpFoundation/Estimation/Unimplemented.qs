// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

// Functionality needed to account for the cost of an operation that is not implemented.
// The cost estimated separately and passed to the `UnimplementedOperation` becomes
// incorporated into the overall program cost. This functionality is only available
// when using resource estimator execution target. `UnimplementedOperation' is not
// defined for other execution targets.

namespace Microsoft.Quantum.ResourceEstimation {

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
    /// Returns a tuple that can be passed to the `UnimplementedOperation`
    /// to specify that the number of the T gates is equal to the `amount`.
    function TCountCost(amount : Int) : (Int, Int) {
        return (TCountKey(), amount);
    }

    /// # Summary
    /// Returns a tuple that can be passed to the `UnimplementedOperation`
    /// to specify that the number of rotations is equal to the `amount`.
    function RotationCountCost(amount : Int) : (Int, Int) {
        return (RotationCountKey(), amount);
    }

    /// # Summary
    /// Returns a tuple that can be passed to the `UnimplementedOperation`
    /// to specify that the rotation depth is equal to the `amount`.
    function RotationDepthCost(amount : Int) : (Int, Int) {
        return (RotationDepthKey(), amount);
    }

    /// # Summary
    /// Returns a tuple that can be passed to the `UnimplementedOperation`
    /// to specify that the number of the CCZ gates is equal to the `amount`.
    function CczCountCost(amount : Int) : (Int, Int) {
        return (CczCountKey(), amount);
    }

    /// # Summary
    /// Returns a tuple that can be passed to the `UnimplementedOperation`
    /// to specify that the number Measurements is equal to the `amount`.
    function MeasurementCountCost(amount : Int) : (Int, Int) {
        return (MeasurementCountKey(), amount);
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
    /// Array of tuples containing costs of the operation. For example, if the operation uses three
    /// T gates, pass the tuple returned by TCountCost(3) as one of the array elements.
    operation UnimplementedOperation(arguments: Qubit[], auxQubitCount: Int, cost: (Int, Int)[]): Unit is Adj {
        body intrinsic;
        adjoint self;
    }

}

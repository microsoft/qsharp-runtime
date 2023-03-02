// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

// Functionality needed to account for the cost of an operation that is not implemented.
// The cost, which is estimated separately and passed to the `EstimateUnimplementedOperation`
// becomes incorporated into the overall program cost. This functionality is only available
// when using resource estimator execution target. `EstimateUnimplementedOperation' is not
// defined for other execution targets.

namespace Microsoft.Quantum.ResourceEstimation {

    /// # Summary
    /// Returns a tuple that can be passed to the `EstimateUnimplementedOperation`
    /// to specify that the number of auxilliary qubits is equal to the `amount`.
    function AuxQubitCountCost(amount : Int) : (Int, Int) {
        return (0, amount);
    }

    /// # Summary
    /// Returns a tuple that can be passed to the `EstimateUnimplementedOperation`
    /// to specify that the number of the T gates is equal to the `amount`.
    function TCountCost(amount : Int) : (Int, Int) {
        return (1, amount);
    }

    /// # Summary
    /// Returns a tuple that can be passed to the `EstimateUnimplementedOperation`
    /// to specify that the number of rotations is equal to the `amount`.
    function RotationCountCost(amount : Int) : (Int, Int) {
        return (2, amount);
    }

    /// # Summary
    /// Returns a tuple that can be passed to the `EstimateUnimplementedOperation`
    /// to specify that the rotation depth is equal to the `amount`.
    function RotationDepthCost(amount : Int) : (Int, Int) {
        return (3, amount);
    }

    /// # Summary
    /// Returns a tuple that can be passed to the `EstimateUnimplementedOperation`
    /// to specify that the number of the CCZ gates is equal to the `amount`.
    function CczCountCost(amount : Int) : (Int, Int) {
        return (4, amount);
    }

    /// # Summary
    /// Returns a tuple that can be passed to the `EstimateUnimplementedOperation`
    /// to specify that the number Measurements is equal to the `amount`.
    function MeasurementCountCost(amount : Int) : (Int, Int) {
        return (5, amount);
    }

    /// # Summary
    /// Account for the cost of an unimplemented operation which is estimated separately.
    /// # Input
    /// ## cost
    /// Array of tuples containing costs of the operation. For example, if the operation uses three
    /// T gates, pass the tuple returned by TCountCost(3) as one of the array elements.
    /// ## arguments
    /// Operation takes these qubits as its arguments.
    operation EstimateUnimplementedOperation(cost: (Int, Int)[], arguments: Qubit[]): Unit is Adj {
        body intrinsic;
        adjoint self;
    }

}

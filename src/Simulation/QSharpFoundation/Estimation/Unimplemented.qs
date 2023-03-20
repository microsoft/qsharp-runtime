// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

// Functionality needed to account for the resource estimates of an operation
// that is not implemented. Estimates that are obtained separately and passed to the
// `AccountForEstimates` become incorporated into the overall program estimates.
// This functionality is only available when using resource estimator execution target.
// `AccountForEstimates' is not defined for other execution targets.

namespace Microsoft.Quantum.ResourceEstimation {

    /// # Summary
    /// Returns a tuple that can be passed to the `AccountForEstimates` operation
    /// to specify that the number of auxilliary qubits is equal to the `amount`.
    function AuxQubitCount(amount : Int) : (Int, Int) {
        return (0, amount);
    }

    /// # Summary
    /// Returns a tuple that can be passed to the `AccountForEstimates` operation
    /// to specify that the number of the T gates is equal to the `amount`.
    function TCount(amount : Int) : (Int, Int) {
        return (1, amount);
    }

    /// # Summary
    /// Returns a tuple that can be passed to the `AccountForEstimates` operation
    /// to specify that the number of rotations is equal to the `amount`.
    function RotationCount(amount : Int) : (Int, Int) {
        return (2, amount);
    }

    /// # Summary
    /// Returns a tuple that can be passed to the `AccountForEstimates` operation
    /// to specify that the rotation depth is equal to the `amount`.
    function RotationDepth(amount : Int) : (Int, Int) {
        return (3, amount);
    }

    /// # Summary
    /// Returns a tuple that can be passed to the `AccountForEstimates` operation
    /// to specify that the number of the CCZ gates is equal to the `amount`.
    function CczCount(amount : Int) : (Int, Int) {
        return (4, amount);
    }

    /// # Summary
    /// Returns a tuple that can be passed to the `AccountForEstimates` operation
    /// to specify that the number Measurements is equal to the `amount`.
    function MeasurementCount(amount : Int) : (Int, Int) {
        return (5, amount);
    }

    /// # Summary
    /// Pass the value returned by the function to the `AccountForEstimates` operation
    /// to indicate Parallel Synthesis Sequential Pauli Computation (PSSPC) layout.
    /// See https://arxiv.org/pdf/2211.07629.pdf for details.
    function PSSPCLayout() : Int {
        return 1;
    }

    /// # Summary
    /// Account for the resource estimates of an unimplemented operation,
    /// which were obtainted separately. This operation is only available
    /// when using resource estimator execution target.
    /// # Input
    /// ## cost
    /// Array of tuples containing resource estimates of the operation. For example,
    /// if the operation uses three T gates, pass the tuple returned by TCount(3)
    /// as one of the array elements.
    /// ## layout
    /// Provides layout scheme that is used to convert logical resource estimates
    /// to physical resource estimates.
    /// ## arguments
    /// Operation takes these qubits as its arguments.
    operation AccountForEstimates(estimates: (Int, Int)[], layout: Int, arguments: Qubit[]): Unit is Adj {
        body intrinsic;
        adjoint self;
    }

}

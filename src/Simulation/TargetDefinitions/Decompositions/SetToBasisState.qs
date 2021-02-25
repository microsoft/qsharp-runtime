// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Measurement {
    open Microsoft.Quantum.Intrinsic;

    /// # Summary
    /// Sets a qubit to a given computational basis state by measuring the
    /// qubit and applying a bit flip if needed.
    ///
    /// # Input
    /// ## desired
    /// The basis state that the qubit should be set to.
    /// ## target
    /// The qubit whose state is to be set.
    ///
    /// # Remarks
    /// As an invariant of this operation, calling `M(q)` immediately
    /// after `SetToBasisState(result, q)` will return `result`.
    operation SetToBasisState(desired : Result, target : Qubit) : Unit {
        if (desired != M(target)) {
            X(target);
        }
    }
}
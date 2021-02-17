// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Intrinsic {

    /// # Summary
    /// Performs the identity operation (no-op) on a single qubit.
    ///
    /// # Remarks
    /// This is a no-op. It is provided for completeness and because
    /// sometimes it is useful to call the identity in an algorithm or to pass it as a parameter.
    operation I (target : Qubit) : Unit is Adj + Ctl {
        body (...) { }
        adjoint self;
    }
}
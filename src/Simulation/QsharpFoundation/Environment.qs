// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

/// # Summary
/// These functions provide information about the environment in which the quantum computation is occuring.
namespace Microsoft.Quantum.Environment {
    /// # Summary
    /// Returns the number of qubits currently available to use.
    ///
    /// # Output
    /// The number of qubits that could be allocated in a `using` statement.
    /// If the target machine being used does not provide this information, then
    /// `-1` is returned.
    ///
    /// # See Also
    /// - GetQubitsAvailableToBorrow
    operation GetQubitsAvailableToUse () : Int {
        body intrinsic;
    }

    /// # Summary
    /// Returns the number of qubits currently available to borrow.
    ///
    /// # Output
    /// The number of qubits that could be borrowed and 
    /// won't be allocated as part of a `borrowing` statement.
    /// If the target machine being used does not provide this information, then
    /// `-1` is returned.
    ///
    /// # See Also
    /// - GetQubitsAvailableToUse
    operation GetQubitsAvailableToBorrow () : Int {
        body intrinsic;
    }
}



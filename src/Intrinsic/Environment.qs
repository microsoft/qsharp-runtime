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
        return -1;
    }

    /// # Summary
    /// Returns the number of qubits currently available to borrow.
    /// This includes unused qubits; that is, this includes the qubits
    /// returned by `GetQubitsAvailableToUse`.
    ///
    /// # Output
    /// The number of qubits that could be allocated in a `borrowing` statement.
    /// If the target machine being used does not provide this information, then
    /// `-1` is returned.
    ///
    /// # See Also
    /// - GetQubitsAvailableToUse
    operation GetQubitsAvailableToBorrow () : Int {
        return -1;
    }
}



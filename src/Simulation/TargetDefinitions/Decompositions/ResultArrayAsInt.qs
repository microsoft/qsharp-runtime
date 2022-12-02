namespace Microsoft.Quantum.Convert {
    open Microsoft.Quantum.Arrays;

    /// # Summary
    /// Produces a non-negative integer from a string of Results in little endian format.
    ///
    /// # Input
    /// ## results
    /// Results in binary representation of number.
    function ResultArrayAsInt(results : Result[]) : Int {
        mutable val = 0;
        for i in IndexRange(results) {
            set val += results[i] == One ? 2 ^ i | 0;
        }
        return val;
    }

}

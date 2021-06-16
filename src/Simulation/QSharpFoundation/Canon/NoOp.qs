// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Canon {

    /// # Summary
    /// Performs the identity operation (no-op) on an argument.
    ///
    /// # Description
    /// This operation takes a value of any type and does nothing to it.
    /// This can be useful whenever an input of an operation type is expected,
    /// but no action should be taken.
    /// For instance, if a particular error correction syndrome indicates that
    /// no error has occurred, `NoOp<Qubit[]>` may be the correct recovery
    /// procedure.
    /// Similarly, if an operation expects a state preparation procedure as
    /// input, `NoOp<Qubit[]>` can be used to prepare the state
    /// $\ket{0 \cdots 0}$.
    ///
    /// # Input
    /// ## input
    /// A value to be ignored.
    ///
    /// # See Also
    /// - Microsoft.Quantum.Intrinsic.I
    operation NoOp<'T>(input : 'T) : Unit is Adj + Ctl {
    }


    /// # Summary
    /// Ignores the output of an operation or function.
    ///
    /// # Input
    /// ## value
    /// A value to be ignored.
    function Ignore<'T> (value : 'T) : Unit {
        return ();
    }

}

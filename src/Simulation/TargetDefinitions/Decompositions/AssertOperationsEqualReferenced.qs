// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Diagnostics {
    open Microsoft.Quantum.Intrinsic;

    /// # Summary
    /// Given two registers, prepares the maximally entangled state 
    /// between each pair of qubits on the respective registers.
    /// All qubits must start in the |0⟩ state.
    ///
    /// The result is that corresponding pairs of qubits from each register are in the
    /// $\bra{\beta_{00}}\ket{\beta_{00}}$.
    ///
    /// # Input
    /// ## left
    /// A qubit array in the $\ket{0\cdots 0}$ state
    /// ## right
    /// A qubit array in the $\ket{0\cdots 0}$ state
    internal operation PrepareEntangledState (left : Qubit[], right : Qubit[]) : Unit
    is Adj + Ctl {

        for idxQubit in 0 .. Length(left) - 1
        {
            H(left[idxQubit]);
            Controlled X([left[idxQubit]], right[idxQubit]);
        }
    }
    
    
    /// # Summary
    /// Given two operations, asserts that they act identically for all input states.
    ///
    /// This assertion is implemented by using the Choi–Jamiołkowski isomorphism to reduce
    /// the assertion to one of a qubit state assertion on two entangled registers.
    /// Thus, this operation needs only a single call to each operation being tested,
    /// but requires twice as many qubits to be allocated.
    /// This assertion can be used to ensure, for instance, that an optimized version of an
    /// operation acts identically to its naïve implementation, or that an operation
    /// which acts on a range of non-quantum inputs agrees with known cases.
    ///
    /// # Remarks
    /// This operation requires that the operation modeling the expected behavior is
    /// adjointable, so that the inverse can be performed on the target register alone.
    /// Formally, one can specify a transpose operation, which relaxes this requirement,
    /// but the transpose operation is not in general physically realizable for arbitrary
    /// quantum operations and thus is not included here as an option.
    ///
    /// # Input
    /// ## nQubits
    /// Number of qubits to pass to each operation.
    /// ## actual
    /// Operation to be tested.
    /// ## expected
    /// Operation defining the expected behavior for the operation under test.
    operation AssertOperationsEqualReferenced (nQubits : Int, actual : (Qubit[] => Unit), expected : (Qubit[] => Unit is Adj)) : Unit {
        // Prepare a reference register entangled with the target register.
        use (reference, target) = (Qubit[nQubits], Qubit[nQubits]) {
            PrepareEntangledState(reference, target);
            actual(target);
            Adjoint expected(target);
            Adjoint PrepareEntangledState(reference, target);
            AssertAllZero(reference + target);
            ResetAll(target);
            ResetAll(reference);
        }
    }

}



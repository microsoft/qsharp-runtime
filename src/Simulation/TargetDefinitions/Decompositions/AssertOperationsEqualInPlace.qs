// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.


namespace Microsoft.Quantum.Diagnostics {
    open Microsoft.Quantum.Intrinsic;

    /// # Summary
    /// Iterates a variable through a Cartesian product
    /// [ 0, bounds[0]-1 ] × [ 0, bounds[1]-1 ] × [ 0, bounds[Length(bounds)-1]-1 ]
    /// and calls op(arr) for every element of the Cartesian product
    internal operation IterateThroughCartesianPower (length : Int, value : Int, op : (Int[] => Unit)) : Unit {
        mutable bounds = new Int[length];

        for i in 0 .. length - 1
        {
            set bounds = bounds w/ i <- value;
        }

        mutable arr = new Int[length];
        mutable finished = false;

        repeat
        {
            if (not finished)
            {
                op(arr);
            }
        }
        until (finished)
        fixup
        {
            //computes the next element in the Cartesian product
            set arr = arr w/ 0 <- arr[0] + 1;

            for i in 0 .. Length(arr) - 2
            {
                if (arr[i] == bounds[i])
                {
                    set arr = arr w/ i + 1 <- arr[i + 1] + 1;
                    set arr = arr w/ i <- 0;
                }
            }

            if (arr[Length(arr) - 1] == bounds[Length(arr) - 1])
            {
                set finished = true;
            }
        }
    }

    /// # Summary
    /// Applies unitaries that map $\ket{0}\otimes\cdots\ket{0}$
    /// to $\ket{\psi_0} \otimes \ket{\psi_{n - 1}}$,
    /// where $\ket{\psi_k}$ depends on `basis[k]`.
    ///
    /// The correspondence between
    /// value of `basis[k]` and $\ket{\psi_k}$ is the following:
    /// - `basis[k]=0` $\rightarrow \ket{0}$.
    /// - `basis[k]=1` $\rightarrow \ket{1}$.
    /// - `basis[k]=2` $\rightarrow \ket{+}$.
    /// - `basis[k]=3` $\rightarrow \ket{i}$ ( +1 eigenstate of Pauli Y ).
    ///
    /// # Input
    /// ## qubits
    /// Qubit to be operated on.
    /// ## basis
    /// Array of single-qubit basis state IDs (0 <= id <= 3), one for each element of
    /// qubits.
    internal operation FlipToBasis (basis : Int[], qubits : Qubit[]) : Unit is Adj + Ctl {
        if (Length(qubits) != Length(basis))
        {
            fail "qubits and stateIds must have the same length";
        }
            
        for i in 0 .. Length(qubits) - 1
        {
            let id = basis[i];
            let qubit = qubits[i];
                
            if (id < 0 or id > 3) {
                fail $"Invalid basis. Must be between 0 and 3, it was {basis}";
            }
                
            if (id == 0)
            {
                I(qubit);
            }
            elif (id == 1)
            {
                X(qubit);
            }
            elif (id == 2)
            {
                H(qubit);
            }
            else
            {
                H(qubit);
                S(qubit);
            }
        }
    }
    
    
    /// # Summary
    /// Checks if the result of applying two operations `givenU` and `expectedU` to
    /// a basis state is the same. The basis state is described by `basis` parameter.
    /// See <xref:microsoft.quantum.extensions.FlipToBasis> function for more details on this
    /// description.
    ///
    /// # Input
    /// ## basis
    /// Basis state specified by a single-qubit basis state ID (0 <= id <= 3) for each of
    /// $n$ qubits.
    /// ## givenU
    /// Operation on $n$ qubits to be checked.
    /// ## expectedU
    /// Reference operation on $n$ qubits that givenU is to be compared against.
    internal operation AssertEqualOnBasisVector (basis : Int[], givenU : (Qubit[] => Unit), expectedU : (Qubit[] => Unit is Adj)) : Unit {
        let tolerance = 1e-5;

        use qubits = Qubit[Length(basis)] {
            AssertAllZeroWithinTolerance(qubits, tolerance);
            FlipToBasis(basis, qubits);
            givenU(qubits);
            Adjoint expectedU(qubits);
            Adjoint FlipToBasis(basis, qubits);
            AssertAllZeroWithinTolerance(qubits, tolerance);
        }
    }

    /// # Summary
    /// Given two operations, asserts that they act identically for all input states.
    ///
    /// This assertion is implemented by checking the action of the operations
    /// on all states of the form $V_0 \otimes ... \otimes V_{n-1}$, where
    /// $V_k$ is one of the states $\ket{0}$, $\ket{1}$, $\ket{+}$ and $\ket{i}$ (+1 eigenstate of Pauli Y operator).
    ///
    /// This assertion uses $n$ qubits and requires multiple calls of the operations being compared.
    ///
    /// # Input
    /// ## nQubits
    /// The number of qubits $n$ that the operations `givenU` and `expectedU` operate on.
    /// ## givenU
    /// Operation on $n$ qubits to be checked.
    /// ## expectedU
    /// Reference operation on $n$ qubits that `givenU` is to be compared against.
    ///
    /// # See Also
    /// - AssertOperationsEqualReferenced
    ///
    /// # References
    /// The basis of states $\ket{0}$, $\ket{1}$, $\ket{+}$ and $\ket{i}$ is the Chuang-Nielsen basis,
    /// described in [ *I. L. Chuang, M. A. Nielsen* ](https://arxiv.org/abs/quant-ph/9610001).
    operation AssertOperationsEqualInPlace(nQubits : Int, givenU : (Qubit[] => Unit), expectedU : (Qubit[] => Unit is Adj)) : Unit
    {
        let checkOperation = AssertEqualOnBasisVector(_, givenU, expectedU);
        IterateThroughCartesianPower(nQubits, 4, checkOperation);
    }

    /// # Summary
    /// Checks if the operation `givenU` is equal to the operation `expectedU` on
    /// the given input size  by checking the action of the operations only on
    /// the vectors from the computational basis.
    /// This is a necessary, but not sufficient, condition for the equality of
    /// two unitaries.
    ///
    /// # Input
    /// ## nQubits
    /// The number of qubits $n$ that the operations `givenU` and `expectedU` operate on.
    /// ## givenU
    /// Operation on $n$ qubits to be checked.
    /// ## expectedU
    /// Reference operation on $n$ qubits that `givenU` is to be compared against.
    operation AssertOperationsEqualInPlaceCompBasis (nQubits : Int, givenU : (Qubit[] => Unit), expectedU : (Qubit[] => Unit is Adj)) : Unit
    {
        let checkOperation = AssertEqualOnBasisVector(_, givenU, expectedU);
        IterateThroughCartesianPower(nQubits, 2, checkOperation);
    }
    
}



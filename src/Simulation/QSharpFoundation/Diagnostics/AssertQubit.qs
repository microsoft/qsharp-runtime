// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Diagnostics {
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Math;

    /// # Summary
    /// Asserts that the qubit `q` is in the expected eigenstate of the Pauli Z operator.
    ///
    /// # Input
    /// ## expected
    /// Which state the qubit is expected to be in: `Zero` or `One`.
    ///
    /// ## q
    /// The qubit whose state is asserted.
    ///
    /// # See Also
    /// - AssertQubitIsInStateWithinTolerance
    ///
    /// # Remarks
    /// <xref:microsoft.quantum.diagnostics.assertqubitisinstatewithintolerance> allows for asserting
    /// arbitrary qubit states rather than only $Z$ eigenstates.
    ///
    /// Note that the Adjoint and Controlled versions of this operation will not
    /// check the condition.
    operation AssertQubit (expected : Result, q : Qubit) : Unit is Adj + Ctl {
        AssertMeasurement([PauliZ], [q], expected, $"Qubit in invalid state. Expecting: {expected}");
    }

    /// # Summary
    /// Asserts that the qubit `q` is in the expected eigenstate of the Pauli Z operator up to
    /// a given tolerance.
    ///
    /// # Input
    /// ## expected
    /// Which state the qubit is expected to be in: `Zero` or `One`.
    ///
    /// ## tolerance
    /// Tolerance on the probability of a measurement of the qubit returning the expected
    /// result.
    ///
    /// ## q
    /// The qubit whose state is asserted.
    ///
    /// # See Also
    /// - AssertQubitIsInStateWithinTolerance
    ///
    /// # Remarks
    /// <xref:microsoft.quantum.diagnostics.assertqubitisinstatewithintolerance> allows for asserting
    /// arbitrary qubit states rather than only $Z$ eigenstates.
    ///
    /// Note that the Adjoint and Controlled versions of this operation will not
    /// check the condition.
    operation AssertQubitWithinTolerance(expected : Result, q : Qubit, tolerance : Double) : Unit is Adj + Ctl {
        AssertMeasurementProbability([PauliZ], [q], expected, 1.0, $"Qubit in invalid state. Expecting: {expected} with tolerance {tolerance}", tolerance);
    }

    /// # Summary
    /// Asserts that a qubit in the expected state.
    ///
    /// `expected` represents a complex vector, $\ket{\psi} = \begin{bmatrix}a & b\end{bmatrix}^{\mathrm{T}}$.
    /// The first element of the tuples representing each of $a$, $b$
    /// is the real part of the complex number, while the second one is the imaginary part.
    /// The last argument defines the tolerance with which assertion is made.
    ///
    /// # Input
    /// ## expected
    /// Expected complex amplitudes for $\ket{0}$ and $\ket{1}$, respectively.
    /// ## register
    /// Qubit whose state is to be asserted. Note that this qubit is assumed to be separable
    /// from other allocated qubits, and not entangled.
    ///
    /// ## tolerance
    /// Additive tolerance by which actual amplitudes are allowed to deviate from expected.
    /// See remarks below for details.
    ///
    /// # Example
    /// ```qsharp
    /// using (qubits = Qubit[2]) {
    ///     // Both qubits are initialized as |0〉: a=(1 + 0*i), b=(0 + 0*i)
    ///     AssertQubitIsInStateWithinTolerance((Complex(1., 0.), Complex(0., 0.)), qubits[0], 1e-5);
    ///     AssertQubitIsInStateWithinTolerance((Complex(1., 0.), Complex(0., 0.)), qubits[1], 1e-5);
    ///     Y(qubits[1]);
    ///     // Y |0〉 = i |1〉: a=(0 + 0*i), b=(0 + 1*i)
    ///     AssertQubitIsInStateWithinTolerance((Complex(0., 0.), Complex(0., 1.)), qubits[1], 1e-5);
    /// }
    /// ```
    ///
    /// # Remarks
    /// The following Mathematica code can be used to verify expressions for mi, mx, my, mz:
    /// ```mathematica
    /// {Id, X, Y, Z} = Table[PauliMatrix[k], {k, 0, 3}];
    /// st = {{ reA + I imA }, { reB + I imB} };
    /// M = st . ConjugateTranspose[st];
    /// mx = Tr[M.X] // ComplexExpand;
    /// my = Tr[M.Y] // ComplexExpand;
    /// mz = Tr[M.Z] // ComplexExpand;
    /// mi = Tr[M.Id] // ComplexExpand;
    /// 2 m == Id mi + X mx + Z mz + Y my // ComplexExpand // Simplify
    /// ```
    ///
    /// The tolerance is
    /// the $L\_{\infty}$ distance between 3 dimensional real vector (x₂,x₃,x₄) defined by
    /// $\langle\psi|\psi\rangle = x\_1 I + x\_2 X + x\_3 Y + x\_4 Z$ and real vector (y₂,y₃,y₄) defined by
    /// ρ = y₁I + y₂X + y₃Y + y₄Z where ρ is the density matrix corresponding to the state of the register.
    /// This is only true under the assumption that Tr(ρ) and Tr(|ψ⟩⟨ψ|) are both 1 (e.g. x₁ = 1/2, y₁ = 1/2).
    /// If this is not the case, the function asserts that l∞ distance between
    /// (x₂-x₁,x₃-x₁,x₄-x₁,x₄+x₁) and (y₂-y₁,y₃-y₁,y₄-y₁,y₄+y₁) is less than the tolerance parameter.
    /// 
    /// Note that the Adjoint and Controlled versions of this operation will not
    /// check the condition.
    operation AssertQubitIsInStateWithinTolerance(expected : (Complex, Complex), register : Qubit, tolerance : Double) : Unit is Adj + Ctl {
        let (a, b) = expected;
        let (reA, imA) = a!;
        let (reB, imB) = b!;
        
        // let M be a density matrix corresponding to state. It is given by:
        // [ [ imA^2 + reA^2,                            imA imB + reA reB + I (-imB reA + imA reB) ]
        //   [imA imB + reA reB + i (imB reA - imA reB), imB^2 + reB^2                              ] ]
        // then
        // mx = Tr(M X), where Tr is a trace function and I,X,Y,Z are Pauli matrices
        let mx = (2.0 * imA) * imB + (2.0 * reA) * reB;
        
        // my = Tr(M Y)
        let my = (2.0 * imB) * reA - (2.0 * imA) * reB;
        
        // mz = Tr(M Z)
        let mz = ((imA * imA - imB * imB) + reA * reA) - reB * reB;
        
        // mi = Tr(M I)
        let mi = ((imA * imA + imB * imB) + reA * reA) + reB * reB;
        
        // Probability of getting outcome Zero in measuring PauliZ is Tr(M(I+Z)/2) = (mi+mz)/2.0
        // Probability of getting outcome One in measuring PauliZ is Tr(M(I-Z)/2) = (mi-mz)/2.0
        // similarly, we find the probabilities for measuring PauliX,PauliY
        let tol = tolerance / 2.0;
        AssertMeasurementProbability([PauliX], [register], Zero, (mi + mx) / 2.0, $"Qubit Zero probability on X basis failed", tol);
        AssertMeasurementProbability([PauliY], [register], Zero, (mi + my) / 2.0, $"Qubit Zero probability on Y basis failed", tol);
        AssertMeasurementProbability([PauliZ], [register], Zero, (mi + mz) / 2.0, $"Qubit Zero probability on Z basis failed", tol);
        AssertMeasurementProbability([PauliZ], [register], One, (mi - mz) / 2.0, $"Qubit One probability on Z basis failed", tol);
    }
    
}



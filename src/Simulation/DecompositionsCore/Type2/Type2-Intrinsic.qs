// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Intrinsic {

    /// # Summary
    /// Applies the Pauli $X$ gate.
    /// 
    /// \begin{align}
    ///     \sigma_x \mathrel{:=}
    ///     \begin{bmatrix}
    ///         0 & 1 \\\\
    ///         1 & 0
    ///     \end{bmatrix}.
    /// \end{align}
    ///
    /// # Input
    /// ## qubit
    /// Qubit to which the gate should be applied.
    operation X(qubit : Qubit) : Unit is Adj + Ctl {
        body intrinsic;
        adjoint self;
    }

    /// # Summary
    /// Applies the Pauli $Y$ gate.
    ///
    /// \begin{align}
    ///     \sigma_y \mathrel{:=}
    ///     \begin{bmatrix}
    ///         0 & -i \\\\
    ///         i & 0
    ///     \end{bmatrix}.
    /// \end{align}
    ///
    /// # Input
    /// ## qubit
    /// Qubit to which the gate should be applied.
    operation Y(qubit : Qubit) : Unit is Adj + Ctl {
        body intrinsic;
        adjoint self;
    }

    /// # Summary
    /// Applies the Pauli $Z$ gate.
    ///
    /// \begin{align}
    ///     \sigma_z \mathrel{:=}
    ///     \begin{bmatrix}
    ///         1 & 0 \\\\
    ///         0 & -1
    ///     \end{bmatrix}.
    /// \end{align}
    ///
    /// # Input
    /// ## qubit
    /// Qubit to which the gate should be applied.
    operation Z(qubit : Qubit) : Unit is Adj + Ctl {
        body intrinsic;
        adjoint self;
    } 

    /// # Summary
    /// Applies the Hadamard transformation to a single qubit.
    ///
    /// \begin{align}
    ///     H \mathrel{:=}
    ///     \frac{1}{\sqrt{2}}
    ///     \begin{bmatrix}
    ///         1 & 1 \\\\
    ///         1 & -1
    ///     \end{bmatrix}.
    /// \end{align}
    ///
    /// # Input
    /// ## qubit
    /// Qubit to which the gate should be applied.
    operation H(qubit : Qubit) : Unit is Adj + Ctl {
        body intrinsic;
        adjoint self;
    }

    /// # Summary
    /// Applies the π/4 phase gate to a single qubit.
    ///
    /// \begin{align}
    ///     S \mathrel{:=}
    ///     \begin{bmatrix}
    ///         1 & 0 \\\\
    ///         0 & i
    ///     \end{bmatrix}.
    /// \end{align}
    ///
    /// # Input
    /// ## qubit
    /// Qubit to which the gate should be applied.
    operation S(qubit : Qubit) : Unit is Adj + Ctl {
        body intrinsic;
    }

    /// # Summary
    /// Applies the π/8 gate to a single qubit.
    ///
    /// # Description
    /// \begin{align}
    ///     T \mathrel{:=}
    ///     \begin{bmatrix}
    ///         1 & 0 \\\\
    ///         0 & e^{i \pi / 4}
    ///     \end{bmatrix}.
    /// \end{align}
    ///
    /// # Input
    /// ## qubit
    /// Qubit to which the gate should be applied.
    operation T(qubit : Qubit) : Unit is Adj + Ctl {
        body intrinsic;
    }

    /// # Summary
    /// Applies the SWAP gate to a pair of qubits.
    ///
    /// # Description
    /// \begin{align}
    ///     \operatorname{SWAP} \mathrel{:=}
    ///     \begin{bmatrix}
    ///         1 & 0 & 0 & 0 \\\\
    ///         0 & 0 & 1 & 0 \\\\
    ///         0 & 1 & 0 & 0 \\\\
    ///         0 & 0 & 0 & 1
    ///     \end{bmatrix},
    /// \end{align}
    ///
    /// where rows and columns are ordered as in the quantum concepts guide.
    ///
    /// # Input
    /// ## qubit1
    /// First qubit to be swapped.
    /// ## qubit2
    /// Second qubit to be swapped.
    operation SWAP(qubit0 : Qubit, qubit1 : Qubit) : Unit is Adj + Ctl {
        body intrinsic;
        adjoint self;
    }

    /// # Summary
    /// Applies a rotation about the given Pauli axis.
    ///
    /// # Description
    /// \begin{align}
    ///     R_{\mu}(\theta) \mathrel{:=}
    ///     e^{-i \theta \sigma_{\mu} / 2},
    /// \end{align}
    /// where $\mu \in \{I, X, Y, Z\}$.
    ///
    /// # Input
    /// ## pauli
    /// Pauli operator ($\mu$) to be exponentiated to form the rotation.
    /// ## theta
    /// Angle about which the qubit is to be rotated.
    /// ## qubit
    /// Qubit to which the gate should be applied.
    ///
    /// # Remarks
    /// When called with `pauli = PauliI`, this operation applies
    /// a *global phase*. This phase can be significant
    /// when used with the `Controlled` functor.
    operation R(pauli : Pauli, theta : Double, qubit : Qubit) : Unit is Adj + Ctl {
        body intrinsic;
    }

    /// # Summary
    /// Performs a measurement of a single qubit in the
    /// Pauli $Z$ basis.
    ///
    /// # Description
    /// The output result is given by
    /// the distribution
    /// \begin{align}
    ///     \Pr(\texttt{Zero} | \ket{\psi}) =
    ///         \braket{\psi | 0} \braket{0 | \psi}.
    /// \end{align}
    ///
    /// # Input
    /// ## qubit
    /// Qubit to be measured.
    ///
    /// # Output
    /// `Zero` if the $+1$ eigenvalue is observed, and `One` if
    /// the $-1$ eigenvalue is observed.
    operation M(qubit : Qubit) : Result {
        body intrinsic;
    }

    /// # Summary
    /// Given a single qubit, measures it and ensures it is in the |0⟩ state
    /// such that it can be safely released.
    ///
    /// # Input
    /// ## qubit
    /// The qubit whose state is to be reset to $\ket{0}$.
    operation Reset(qubit : Qubit) : Unit {
        body intrinsic;
    }

}
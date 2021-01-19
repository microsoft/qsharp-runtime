// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Intrinsic {
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Targeting;

    @Deprecated("Microsoft.Quantum.Random.DrawCategorical")
    operation Random (probs : Double[]) : Int {
        body intrinsic;
    }    
    
    @Deprecated("Microsoft.Quantum.Diagnostics.AssertMeasurement")
    operation Assert (bases : Pauli[], qubits : Qubit[], result : Result, msg : String) : Unit
    is Adj + Ctl {
        Microsoft.Quantum.Diagnostics.AssertMeasurement(bases, qubits, result, msg);
    }
    
    @Deprecated("Microsoft.Quantum.Diagnostics.AssertMeasurementProbability")
    operation AssertProb (bases : Pauli[], qubits : Qubit[], result : Result, prob : Double, msg : String, tol : Double) : Unit
    is Adj + Ctl {
        Microsoft.Quantum.Diagnostics.AssertMeasurementProbability(bases, qubits, result, prob, msg, tol);
    }
    
    
    /// # Summary
    /// Logs a message.
    ///
    /// # Input
    /// ## msg
    /// The message to be reported.
    ///
    /// # Remarks
    /// The specific behavior of this function is simulator-dependent,
    /// but in most cases the given message will be written to the console.
    function Message (msg : String) : Unit {
        body intrinsic;
    }
    
    
    //-------------------------------------------------
    // Clifford and related operations  
    //-------------------------------------------------
    
    /// # Summary
    /// Performs the identity operation (no-op) on a single qubit.
    ///
    /// # Remarks
    /// This is a no-op. It is provided for completeness and because
    /// sometimes it is useful to call the identity in an algorithm or to pass it as a parameter.
    operation I (target : Qubit) : Unit
    is Adj + Ctl {
        body (...) { }        
        adjoint self;
    }
    
    
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
    operation X (qubit : Qubit) : Unit
    is Adj + Ctl {
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
    operation Y (qubit : Qubit) : Unit
    is Adj + Ctl {
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
    operation Z (qubit : Qubit) : Unit
    is Adj + Ctl {
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
    operation H (qubit : Qubit) : Unit
    is Adj + Ctl {
        body intrinsic;
        adjoint self;
    }   
    
    
    /// # Summary
    /// Applies the S gate to a single qubit.
    ///
    /// # Description
    /// This operation can be simulated by the unitary matrix
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
    operation S(qubit : Qubit) : Unit
    is Adj + Ctl {
        body intrinsic;
    }   
    
    
    /// # Summary
    /// Applies the T gate to a single qubit.
    ///
    /// # Description
    /// This operation can be simulated by the unitary matrix
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
    operation T(qubit : Qubit) : Unit
    is Adj + Ctl {
        body intrinsic;
    }   
    
    
    /// # Summary
    /// Applies the controlled-NOT (CNOT) gate to a pair of qubits.
    ///
    /// \begin{align}
    ///     \operatorname{CNOT} \mathrel{:=}
    ///     \begin{bmatrix}
    ///         1 & 0 & 0 & 0 \\\\
    ///         0 & 1 & 0 & 0 \\\\
    ///         0 & 0 & 0 & 1 \\\\
    ///         0 & 0 & 1 & 0
    ///     \end{bmatrix},
    /// \end{align}
    ///
    /// where rows and columns are ordered as in the quantum concepts guide.
    ///
    /// # Input
    /// ## control
    /// Control qubit for the CNOT gate.
    /// ## target
    /// Target qubit for the CNOT gate.
    ///
    /// # Remarks
    /// Equivalent to:
    /// ```qsharp
    /// Controlled X([control], target);
    /// ```
    operation CNOT (control : Qubit, target : Qubit) : Unit
    is Adj + Ctl {

        body (...) {
            Controlled X([control], target);
        }
        
        adjoint self;
    }
    
    
    /// # Summary
    /// Applies the doubly controlled–NOT (CCNOT) gate to three qubits.
    ///
    /// # Input
    /// ## control1
    /// First control qubit for the CCNOT gate.
    /// ## control2
    /// Second control qubit for the CCNOT gate.
    /// ## target
    /// Target qubit for the CCNOT gate.
    ///
    /// # Remarks
    /// Equivalent to:
    /// ```qsharp
    /// Controlled X([control1, control2], target);
    /// ```
    operation CCNOT (control1 : Qubit, control2 : Qubit, target : Qubit) : Unit
    is Adj + Ctl {
        body (...) {
            Controlled X([control1, control2], target);
        }
        
        adjoint self;
    }
    
    
    /// # Summary
    /// Applies the SWAP gate to a pair of qubits.
    ///
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
    ///
    /// # Remarks
    /// Equivalent to:
    /// ```qsharp
    /// CNOT(qubit1, qubit2);
    /// CNOT(qubit2, qubit1);
    /// CNOT(qubit1, qubit2);
    /// ```
    operation SWAP (qubit1 : Qubit, qubit2 : Qubit) : Unit
    is Adj + Ctl {
        body (...)
        {
            within {
                CNOT(qubit1, qubit2);
            } apply {
                CNOT(qubit2, qubit1);
            }
        }
        
        adjoint self;
    }

    //-------------------------------------------------
    // Rotations
    //-------------------------------------------------
    
    /// # Summary
    /// Applies a rotation about the given Pauli axis.
    ///
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
    operation R (pauli : Pauli, theta : Double, qubit : Qubit) : Unit
    is Adj + Ctl {
        body intrinsic;
    }   
    
    
    /// # Summary
    /// Applies a rotation about the given Pauli axis by an angle specified
    /// as a dyadic fraction.
    ///
    /// \begin{align}
    ///     R_{\mu}(n, k) \mathrel{:=}
    ///     e^{i \pi n \sigma_{\mu} / 2^k},
    /// \end{align}
    /// where $\mu \in \{I, X, Y, Z\}$.
    ///
    /// > [!WARNING]
    /// > This operation uses the **opposite** sign convention from
    /// > @"microsoft.quantum.intrinsic.r".
    ///
    /// # Input
    /// ## pauli
    /// Pauli operator to be exponentiated to form the rotation.
    /// ## numerator
    /// Numerator in the dyadic fraction representation of the angle
    /// by which the qubit is to be rotated.
    /// ## power
    /// Power of two specifying the denominator of the angle by which
    /// the qubit is to be rotated.
    /// ## qubit
    /// Qubit to which the gate should be applied.
    ///
    /// # Remarks
    /// Equivalent to:
    /// ```qsharp
    /// // PI() is a Q# function that returns an approximation of π.
    /// R(pauli, -PI() * IntAsDouble(numerator) / IntAsDouble(2 ^ (power - 1)), qubit);
    /// ```
    operation RFrac (pauli : Pauli, numerator : Int, power : Int, qubit : Qubit) : Unit
    is Adj + Ctl {

        let angle = ((-2.0 * PI()) * IntAsDouble(numerator)) / IntAsDouble(2 ^ power);
        R(pauli, angle, qubit);
    }
    
    
    /// # Summary
    /// Applies a rotation about the $x$-axis by a given angle.
    ///
    /// \begin{align}
    ///     R_x(\theta) \mathrel{:=}
    ///     e^{-i \theta \sigma_x / 2} = 
    ///     \begin{bmatrix}
    ///         \cos \frac{\theta}{2} & -i\sin \frac{\theta}{2}  \\\\
    ///         -i\sin \frac{\theta}{2} & \cos \frac{\theta}{2}
    ///     \end{bmatrix}.
    /// \end{align}
    ///
    /// # Input
    /// ## theta
    /// Angle about which the qubit is to be rotated.
    /// ## qubit
    /// Qubit to which the gate should be applied.
    ///
    /// # Remarks
    /// Equivalent to:
    /// ```qsharp
    /// R(PauliX, theta, qubit);
    /// ```
    operation Rx (theta : Double, qubit : Qubit) : Unit
    is Adj + Ctl {
        body (...)
        {
            R(PauliX, theta, qubit);
        }
        
        adjoint (...)
        {
            R(PauliX, -theta, qubit);
        }
    }
    
    
    /// # Summary
    /// Applies a rotation about the $y$-axis by a given angle.
    ///
    /// \begin{align}
    ///     R_y(\theta) \mathrel{:=}
    ///     e^{-i \theta \sigma_y / 2} = 
    ///     \begin{bmatrix}
    ///         \cos \frac{\theta}{2} & -\sin \frac{\theta}{2}  \\\\
    ///         \sin \frac{\theta}{2} & \cos \frac{\theta}{2}
    ///     \end{bmatrix}.
    /// \end{align}
    ///
    /// # Input
    /// ## theta
    /// Angle about which the qubit is to be rotated.
    /// ## qubit
    /// Qubit to which the gate should be applied.
    ///
    /// # Remarks
    /// Equivalent to:
    /// ```qsharp
    /// R(PauliY, theta, qubit);
    /// ```
    operation Ry (theta : Double, qubit : Qubit) : Unit
    is Adj + Ctl {
        body (...)
        {
            R(PauliY, theta, qubit);
        }
        
        adjoint (...)
        {
            R(PauliY, -theta, qubit);
        }
    }
    
    
    /// # Summary
    /// Applies a rotation about the $z$-axis by a given angle.
    ///
    /// \begin{align}
    ///     R_z(\theta) \mathrel{:=}
    ///     e^{-i \theta \sigma_z / 2} = 
    ///     \begin{bmatrix}
    ///         e^{-i \theta / 2} & 0 \\\\
    ///         0 & e^{i \theta / 2}
    ///     \end{bmatrix}.
    /// \end{align}
    ///
    /// # Input
    /// ## theta
    /// Angle about which the qubit is to be rotated.
    /// ## qubit
    /// Qubit to which the gate should be applied.
    ///
    /// # Remarks
    /// Equivalent to:
    /// ```qsharp
    /// R(PauliZ, theta, qubit);
    /// ```
    operation Rz (theta : Double, qubit : Qubit) : Unit
    is Adj + Ctl {
        body (...)
        {
            R(PauliZ, theta, qubit);
        }
        
        adjoint (...)
        {
            R(PauliZ, -theta, qubit);
        }
    }
    
    
    /// # Summary
    /// Applies a rotation about the $\ket{1}$ state by a given angle.
    ///
    /// \begin{align}
    ///     R_1(\theta) \mathrel{:=}
    ///     \operatorname{diag}(1, e^{i\theta}).
    /// \end{align}
    ///
    /// # Input
    /// ## theta
    /// Angle about which the qubit is to be rotated.
    /// ## qubit
    /// Qubit to which the gate should be applied.
    ///
    /// # Remarks
    /// Equivalent to:
    /// ```qsharp
    /// R(PauliZ, theta, qubit);
    /// R(PauliI, -theta, qubit);
    /// ```
    operation R1 (theta : Double, qubit : Qubit) : Unit
    is Adj + Ctl {

        R(PauliZ, theta, qubit);
        R(PauliI, -theta, qubit);
    }
    
    
    /// # Summary
    /// Applies a rotation about the $\ket{1}$ state by an angle specified
    /// as a dyadic fraction.
    ///
    /// \begin{align}
    ///     R_1(n, k) \mathrel{:=}
    ///     \operatorname{diag}(1, e^{i \pi k / 2^n}).
    /// \end{align}
    ///
    /// > [!WARNING]
    /// > This operation uses the **opposite** sign convention from
    /// > @"microsoft.quantum.intrinsic.r", and does not include the
    /// > factor of $1/ 2$ included by @"microsoft.quantum.intrinsic.r1".
    ///
    /// # Input
    /// ## numerator
    /// Numerator in the dyadic fraction representation of the angle
    /// by which the qubit is to be rotated.
    /// ## power
    /// Power of two specifying the denominator of the angle by which
    /// the qubit is to be rotated.
    /// ## qubit
    /// Qubit to which the gate should be applied.
    ///
    /// # Remarks
    /// Equivalent to:
    /// ```qsharp
    /// RFrac(PauliZ, -numerator, denominator + 1, qubit);
    /// RFrac(PauliI, numerator, denominator + 1, qubit);
    /// ```
    operation R1Frac (numerator : Int, power : Int, qubit : Qubit) : Unit
    is Adj + Ctl {

        RFrac(PauliZ, -numerator, power + 1, qubit);
        RFrac(PauliI, numerator, power + 1, qubit);
    }
    
    
    /// # Summary
    /// Applies the exponential of a multi-qubit Pauli operator.
    ///
    /// \begin{align}
    ///     e^{i \theta [P_0 \otimes P_1 \cdots P_{N-1}]},
    /// \end{align}
    /// where $P_i$ is the $i$th element of `paulis`, and where
    /// $N = $`Length(paulis)`.
    ///
    /// # Input
    /// ## paulis
    /// Array of single-qubit Pauli values indicating the tensor product
    /// factors on each qubit.
    /// ## theta
    /// Angle about the given multi-qubit Pauli operator by which the
    /// target register is to be rotated.
    /// ## qubits
    /// Register to apply the given rotation to.
    operation Exp (paulis : Pauli[], theta : Double, qubits : Qubit[]) : Unit
    is Adj + Ctl {
        body intrinsic;
    }   
    
    
    /// # Summary
    /// Applies the exponential of a multi-qubit Pauli operator
    /// with an argument given by a dyadic fraction.
    ///
    /// \begin{align}
    ///     e^{i \pi k [P_0 \otimes P_1 \cdots P_{N-1}] / 2^n},
    /// \end{align}
    /// where $P_i$ is the $i$th element of `paulis`, and where
    /// $N = $`Length(paulis)`.
    ///
    /// # Input
    /// ## paulis
    /// Array of single-qubit Pauli values indicating the tensor product
    /// factors on each qubit.
    /// ## numerator
    /// Numerator ($k$) in the dyadic fraction representation of the angle
    /// by which the qubit register is to be rotated.
    /// ## power
    /// Power of two ($n$) specifying the denominator of the angle by which
    /// the qubit register is to be rotated.
    /// ## qubits
    /// Register to apply the given rotation to.
    operation ExpFrac (paulis : Pauli[], numerator : Int, power : Int, qubits : Qubit[]) : Unit
    is Adj + Ctl {
        let angle = (PI() * IntAsDouble(numerator)) / IntAsDouble(2 ^ power);
        Exp(paulis, angle, qubits);
    }   
    
    
    //-------------------------------------------------
    // Measurements 
    //-------------------------------------------------
    
    /// # Summary
    /// Performs a joint measurement of one or more qubits in the
    /// specified Pauli bases.
    ///
    /// The output result is given by the distribution:
    /// \begin{align}
    ///     \Pr(\texttt{Zero} | \ket{\psi}) =
    ///         \frac12 \braket{
    ///             \psi \mid|
    ///             \left(
    ///                 \boldone + P_0 \otimes P_1 \otimes \cdots \otimes P_{N-1}
    ///             \right) \mid|
    ///             \psi
    ///         },
    /// \end{align}
    /// where $P_i$ is the $i$th element of `bases`, and where
    /// $N = \texttt{Length}(\texttt{bases})$.
    /// That is, measurement returns a `Result` $d$ such that the eigenvalue of the
    /// observed measurement effect is $(-1)^d$.
    ///
    /// # Input
    /// ## bases
    /// Array of single-qubit Pauli values indicating the tensor product
    /// factors on each qubit.
    /// ## qubits
    /// Register of qubits to be measured.
    ///
    /// # Output
    /// `Zero` if the $+1$ eigenvalue is observed, and `One` if
    /// the $-1$ eigenvalue is observed.
    ///
    /// # Remarks
    /// If the basis array and qubit array are different lengths, then the
    /// operation will fail.
    operation Measure (bases : Pauli[], qubits : Qubit[]) : Result {
        body intrinsic;
    }
    
    
    /// # Summary
    /// Performs a measurement of a single qubit in the
    /// Pauli $Z$ basis.
    ///
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
    ///
    /// # Remarks
    /// Equivalent to:
    /// ```qsharp
    /// Measure([PauliZ], [qubit]);
    /// ```
    operation M (qubit : Qubit) : Result {
        return Measure([PauliZ], [qubit]);
    }


    /// # Summary
    /// Given a single qubit, measures it and ensures it is in the |0⟩ state
    /// such that it can be safely released.
    ///
    /// # Input
    /// ## target
    /// The qubit whose state is to be reset to $\ket{0}$.
    @RequiresCapability(
        "BasicQuantumFunctionality",
        "Reset is replaced by a supported implementation on all execution targets."
    )
    operation Reset (target : Qubit) : Unit {
        if (M(target) == One) {
            X(target);
        }
    }


    /// # Summary
    /// Given an array of qubits, measure them and ensure they are in the |0⟩ state
    /// such that they can be safely released.
    ///
    /// # Input
    /// ## qubits
    /// An array of qubits whose states are to be reset to $\ket{0}$.
    operation ResetAll (qubits : Qubit[]) : Unit {
        for (qubit in qubits) {
            Reset(qubit);
        }
    }
}

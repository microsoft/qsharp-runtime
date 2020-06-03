// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Intrinsic {
    open Microsoft.Quantum.Decompositions.Utilities as Utils;
    open Microsoft.Quantum.Diagnostics;

    /// # Summary
    /// Performs the identity operation (no-op) on a single qubit.
    ///
    /// # Remarks
    /// This is a no-op. It is provided for completeness and because
    /// sometimes it is useful to call the identity in an algorithm or to pass it as a parameter.
    @EnableTestingViaName("Test.Decompositions.I")
    operation I(target : Qubit) : Unit
    is Adj + Ctl {
        body (...) { }
        adjoint self;
    }

    /// # Summary
    /// Applies a rotation about the $x$-axis by a given angle.
    ///
    /// # Description
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
    @EnableTestingViaName("Test.Decompositions.Rx")
    operation Rx(theta : Double, qubit : Qubit) : Unit is Ctl + Adj {
        body(...) {
            R(PauliX, theta, qubit);
        }
        adjoint(...) {
            R(PauliX, -theta, qubit);
        }
    }

    /// # Summary
    /// Applies a rotation about the $y$-axis by a given angle.
    ///
    /// # Description
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
    @EnableTestingViaName("Test.Decompositions.Ry")
    operation Ry(theta : Double, qubit : Qubit) : Unit is Ctl + Adj {
        body(...) {
            R(PauliY, theta, qubit);
        }
        adjoint(...) {
            R(PauliY, -theta, qubit);
        }
    }

    /// # Summary
    /// Applies a rotation about the $z$-axis by a given angle.
    ///
    /// # Description
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
    @EnableTestingViaName("Test.Decompositions.Rz")
    operation Rz(theta : Double, qubit : Qubit) : Unit is Ctl + Adj {
        body(...) {
            R(PauliZ, theta, qubit);
        }
        adjoint(...) {
            R(PauliZ, -theta, qubit);
        }
    }

    /// # Summary
    /// Applies the controlled-NOT (CNOT) gate to a pair of qubits.
    ///
    /// # Description
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
    @EnableTestingViaName("Test.Decompositions.CNOT")
    operation CNOT(control : Qubit, target : Qubit) : Unit is Adj + Ctl {
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
    @EnableTestingViaName("Test.Decompositions.CCNOT")
    operation CCNOT(control1 : Qubit, control2 : Qubit, target : Qubit) : Unit is Adj + Ctl {
        body (...) {
            Controlled X([control1, control2], target);
        }
        adjoint self;
    }

    /// # Summary
    /// Applies a rotation about the $\ket{1}$ state by a given angle.
    ///
    /// # Description
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
    @EnableTestingViaName("Test.Decompositions.R1")
    operation R1(theta : Double, qubit : Qubit) : Unit is Adj + Ctl {
        body(...) {
            ApplyGlobalPhase( theta / 2.0 );
            Rz(theta, qubit);
        }
        adjoint(...) {
            R1(-theta, qubit);
        }
    }

    /// # Summary
    /// Given an array of qubits, measure them and ensure they are in the |0⟩ state
    /// such that they can be safely released.
    ///
    /// # Input
    /// ## qubits
    /// An array of qubits whose states are to be reset to $\ket{0}$.
    @EnableTestingViaName("Test.Decompositions.ResetAll")
    operation ResetAll(qubits : Qubit[]) : Unit {
        for (qubit in qubits) {
            Reset(qubit);
        }
    }

    /// # Summary
    /// Applies the exponential of a multi-qubit Pauli operator.
    ///
    /// # Description
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
    @EnableTestingViaName("Test.Decompositions.Exp")
    operation Exp(paulis : Pauli[], theta : Double, qubits : Qubit[]) : Unit is Adj + Ctl {
        body(...) {
            if (Length(paulis) != Length(qubits)) { fail "Arrays 'pauli' and 'target' must have the same length"; }
            let (newPaulis, newQubits) = Utils.RemovePauliI(paulis, qubits);

            if (Length(newPaulis) != 0) {
                ExpNoId(newPaulis, theta , newQubits);
            }
            else {
                ApplyGlobalPhase(theta);
            }
        }
        adjoint(...) {
            Exp(paulis, -theta, qubits);
        }
    }

    /// # Summary
    /// Applies a rotation about the $\ket{1}$ state by an angle specified
    /// as a dyadic fraction.
    ///
    /// # Description
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
    @EnableTestingViaName("Test.Decompositions.R1Frac")
    operation R1Frac(numerator : Int, power : Int, qubit : Qubit) : Unit is Adj + Ctl {
         DispatchR1Frac(numerator, power, qubit);
    }

    /// # Summary
    /// Applies a rotation about the given Pauli axis by an angle specified
    /// as a dyadic fraction.
    ///
    /// # Description
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
    @EnableTestingViaName("Test.Decompositions.RFrac")
    operation RFrac(pauli : Pauli, numerator : Int, power : Int, qubit : Qubit) : Unit is Adj + Ctl {
        if (pauli == PauliI) {
            ApplyGlobalPhaseFracWithR1Frac(numerator, power);
        }
        else {
            if (power >= 0) { // when power is negative the operation is exp(i P pi*2^|n|*k) = I

                within {
                    MapPauli(qubit, PauliZ, pauli);
                }
                apply {
                    ApplyGlobalPhaseFracWithR1Frac(numerator, power);
                    R1Frac(-numerator, power - 1, qubit);
                }

                //Below is another option for implementing RFrac
                //let (kModPositive,n) = Utils.ReducedDyadicFractionPeriodic(numerator,power); // k is odd, in the range [1,2*2^n-1] or (k,n) are both 0
                //let numeratorD = Microsoft.Quantum.Math.PI() * Microsoft.Quantum.Convert.IntAsDouble(kModPositive);
                //let phi = numeratorD * Microsoft.Quantum.Math.PowD(2.0, Microsoft.Quantum.Convert.IntAsDouble(-n));
                //R(pauli, -2.0 * phi, qubit);

            }
        }
    }

    /// # Summary
    /// Applies the exponential of a multi-qubit Pauli operator
    /// with an argument given by a dyadic fraction.
    ///
    /// # Description
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
    @EnableTestingViaName("Test.Decompositions.ExpFrac")
    operation ExpFrac(paulis : Pauli[], numerator : Int, power : Int, qubits : Qubit[]) : Unit is Adj + Ctl {
        body(...) {
            if (Length(paulis) != Length(qubits)) { fail "Arrays 'pauli' and 'target' must have the same length"; }

            if (Length(paulis) != 0) {
                let indices = Utils.IndicesOfNonIdentity(paulis);
                let newPaulis = Utils.ArrayFromIndiciesP(paulis, indices);
                let newQubits = Utils.ArrayFromIndiciesQ(qubits, indices);

                if (Length(indices) != 0) { ExpNoIdFrac(newPaulis, numerator, power , newQubits); }
                else { ApplyGlobalPhaseFracWithR1Frac(numerator, power); }
            }
        }
        adjoint(...) {
            ExpFrac(paulis, -numerator, power, qubits);
        }
    }

    /// # Summary
    /// Performs a joint measurement of one or more qubits in the
    /// specified Pauli bases.
    ///
    /// # Description
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
    @EnableTestingViaName("Test.Decompositions.Measure")
    operation Measure(bases : Pauli[], qubits : Qubit[]) : Result {
        if (Length(bases) == 1) {
            MapPauli(qubits[0], PauliZ, bases[0]);
            return M(qubits[0]);
        }
        else {
            using (q = Qubit()) {
                within {
                    H(q);
                }
                apply {
                    for (k in 0 .. Length(bases) - 1) {
                        if (bases[k] == PauliX) { Controlled X([qubits[k]], q); }
                        if (bases[k] == PauliZ) { Controlled Z([qubits[k]], q); }
                        if (bases[k] == PauliY) { Controlled Y([qubits[k]], q); }
                    }
                }
                return M(q);
            }
        }
    }

    /// # Summary
    /// Measures a single qubit in the Z basis.
    ///
    /// # Description
    /// Performs a single-qubit measurement in the $Z$-basis.
    ///
    /// # Input
    /// ## target
    /// A single qubit to be measured.
    ///
    /// # Output
    /// The result of measuring `target` in the Pauli $Z$ basis.
    operation MResetZ (target : Qubit) : Result {
        let r = M(target);
        Reset(target);
        return r;
    }


    /// # Summary
    /// Measures a single qubit in the X basis.
    ///
    /// # Description
    /// Performs a single-qubit measurement in the $X$-basis.
    ///
    /// # Input
    /// ## target
    /// A single qubit to be measured.
    ///
    /// # Output
    /// The result of measuring `target` in the Pauli $X$ basis.
    operation MResetX (target : Qubit) : Result {
        let r = Measure([PauliX], [target]);
        Reset(target);
        return r;
    }


    /// # Summary
    /// Measures a single qubit in the Y basis.
    ///
    /// # Description
    /// Performs a single-qubit measurement in the $Y$-basis.
    ///
    /// # Input
    /// ## target
    /// A single qubit to be measured.
    ///
    /// # Output
    /// The result of measuring `target` in the Pauli $Y$ basis.
    operation MResetY (target : Qubit) : Result {
        let r = Measure([PauliY], [target]);
        Reset(target);
        return r;
    }
}
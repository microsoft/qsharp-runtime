// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

// This namespace contains definitions that parallel each operation in
// M.Q.Intrinsic, making it easier to forward intrinsic definitions from the
// simulator.

namespace Microsoft.Quantum.Experimental.Intrinsic {
    open Microsoft.Quantum.Experimental.Native as Native;
    open Microsoft.Quantum.Experimental.Decompositions;

    operation H(target : Qubit) : Unit is Adj + Ctl {
        body (...) {
            Native.H(target);
        }

        controlled (controls, ...) {
            if Length(controls) == 0 {
                H(target);
            } else {
                ApplyControlledH(controls, target);
            }
        }
    }

    operation X(target : Qubit) : Unit is Adj + Ctl {
        body (...) {
            Native.X(target);
        }

        controlled (controls, ...) {
            if Length(controls) == 0 {
                X(target);
            } elif Length(controls) == 1 {
                Native.CNOT(controls[0], target);
            } elif Length(controls) == 2 {
                // Forward to decomposition of CCZ.
                within {
                    H(target);
                } apply {
                    Controlled Z(controls, target);
                }
            } else {
                ApplyWithLessControlsA(Controlled X, (controls, target));
            }
        }
    }

    operation Y(target : Qubit) : Unit is Adj + Ctl {
        body (...) {
            Native.Y(target);
        }

        controlled (controls, ...) {
            if Length(controls) == 0 {
                Y(target);
            } elif Length(controls) == 1 {
                within {
                    Native.H(target);
                    Native.S(target);
                } apply {
                    Native.CNOT(controls[0], target);
                }
            } elif Length(controls) == 2 {
                within {
                    within {
                        Native.H(target);
                    } apply {
                        Native.S(target);
                    }
                } apply {
                    Controlled Z(controls, target);
                }
            } else {
                ApplyWithLessControlsA(Controlled Y, (controls, target));
            }
        }
    }

    operation Z(target : Qubit) : Unit is Adj + Ctl {
        body (...) {
            Native.Z(target);
        }

        controlled (controls, ...) {
            if Length(controls) == 0 {
                Native.Z(target);
            } elif Length(controls) == 1 {
                within {
                    H(target);
                } apply {
                    Native.CNOT(controls[0], target);
                }
            } elif Length(controls) == 2 {
                // [Page 15 of arXiv:1206.0758v3](https://arxiv.org/pdf/1206.0758v3.pdf#page=15)
                Adjoint Native.T(controls[0]);
                Adjoint Native.T(controls[1]);
                Native.CNOT(target, controls[0]);
                Native.T(controls[0]);
                Native.CNOT(controls[1], target);
                Native.CNOT(controls[1], controls[0]);
                Native.T(target);
                Adjoint Native.T(controls[0]);
                Native.CNOT(controls[1], target);
                Native.CNOT(target, controls[0]);
                Adjoint Native.T(target);
                Native.T(controls[0]);
                Native.CNOT(controls[1], controls[0]);
            } else {
                ApplyWithLessControlsA(Controlled Z, (controls, target));
            } 
        }
    }

    operation S(target : Qubit) : Unit is Adj + Ctl {
        body (...) {
            Native.S(target);
        }

        controlled (controls, ...) {
            if Length(controls) == 0 {
                Native.S(target);
            } elif (Length(controls) == 1) {
                Native.T(controls[0]);
                Native.T(target);
                within {
                    Native.CNOT(controls[0], target);
                } apply {
                    Adjoint Native.T(target);
                }
            } else {
                ApplyWithLessControlsA(Controlled S, (controls, target));
            }
        }
    }

    operation T(target : Qubit) : Unit is Adj + Ctl {
        body (...) {
            Native.T(target);
        }

        controlled (controls, ...) {
            if Length(controls) == 0 {
                Native.T(target);
            } else {
                // TODO: Decompositions of `Controlled T` currently used in Q#
                //       target packages rely on R1Frac, which is not yet
                //       implemented in experimental simulation.
                fail "Controlled T operations are not yet supported.";
            }
        }
    }

    operation Rx(theta : Double, qubit : Qubit) : Unit is Adj + Ctl {
        body (...) {
            Native.Rx(theta, qubit);
        }
        controlled (ctls, ...) {
            if Length(ctls) == 0 {
                Native.Rx(theta, qubit);
            }
            else {
                within {
                    MapPauli(qubit, PauliZ, PauliX);
                }
                apply {
                    Controlled Rz(ctls, (theta, qubit));
                }
            }
        }
        adjoint (...) {
            Rx(-theta, qubit);
        }
    }

    operation Ry (theta : Double, qubit : Qubit) : Unit is Adj + Ctl {
        body (...) {
            Native.Ry(theta, qubit);
        }
        controlled (ctls, ...) {
            if Length(ctls) == 0 {
                Native.Ry(theta, qubit);
            }
            else {
                within {
                    MapPauli(qubit, PauliZ, PauliY);
                }
                apply {
                    Controlled Rz(ctls, (theta, qubit));
                }
            }
        }
        adjoint (...) {
            Ry(-theta, qubit);
        }
    }

    operation Rz (theta : Double, qubit : Qubit) : Unit is Adj + Ctl {
        body (...) {
            Native.Rz(theta, qubit);
        }
        controlled (ctls, ...) {
            if Length(ctls) == 0 {
                Native.Rz(theta, qubit);
            }
            elif Length(ctls) == 1 {
                CRz(ctls[0], theta, qubit);
            }
            elif Length(ctls) == 2 {
                use temp = Qubit();
                within {
                    PhaseCCX(ctls[0], ctls[1], temp);
                }
                apply {
                    CRz(temp, theta, qubit);
                }
            }
            elif Length(ctls) == 3 {
                use temps = Qubit[2];
                within {
                    PhaseCCX(ctls[0], ctls[1], temps[0]);
                    PhaseCCX(ctls[2], temps[0], temps[1]);
                }
                apply {
                    CRz(temps[1], theta, qubit);
                }
            }
            elif Length(ctls) == 4 {
                use temps = Qubit[3];
                within {
                    PhaseCCX(ctls[0], ctls[1], temps[0]);
                    PhaseCCX(ctls[2], ctls[3], temps[1]);
                    PhaseCCX(temps[0], temps[1], temps[2]);
                }
                apply {
                    CRz(temps[2], theta, qubit);
                }
            }
            elif Length(ctls) == 5 {
                use temps = Qubit[4];
                within {
                    PhaseCCX(ctls[0], ctls[1], temps[0]);
                    PhaseCCX(ctls[2], ctls[3], temps[1]);
                    PhaseCCX(ctls[4], temps[0], temps[2]);
                    PhaseCCX(temps[1], temps[2], temps[3]);
                }
                apply {
                    CRz(temps[3], theta, qubit);
                }
            }
            elif Length(ctls) == 6 {
                use temps = Qubit[5];
                within {
                    PhaseCCX(ctls[0], ctls[1], temps[0]);
                    PhaseCCX(ctls[2], ctls[3], temps[1]);
                    PhaseCCX(ctls[4], ctls[5], temps[2]);
                    PhaseCCX(temps[0], temps[1], temps[3]);
                    PhaseCCX(temps[2], temps[3], temps[4]);
                }
                apply {
                    CRz(temps[4], theta, qubit);
                }
            }
            elif Length(ctls) == 7 {
                use temps = Qubit[6];
                within {
                    PhaseCCX(ctls[0], ctls[1], temps[0]);
                    PhaseCCX(ctls[2], ctls[3], temps[1]);
                    PhaseCCX(ctls[4], ctls[5], temps[2]);
                    PhaseCCX(ctls[6], temps[0], temps[3]);
                    PhaseCCX(temps[1], temps[2], temps[4]);
                    PhaseCCX(temps[3], temps[4], temps[5]);
                }
                apply {
                    CRz(temps[5], theta, qubit);
                }
            }
            elif Length(ctls) == 8 {
                use temps = Qubit[7];
                within {
                    PhaseCCX(ctls[0], ctls[1], temps[0]);
                    PhaseCCX(ctls[2], ctls[3], temps[1]);
                    PhaseCCX(ctls[4], ctls[5], temps[2]);
                    PhaseCCX(ctls[6], ctls[7], temps[3]);
                    PhaseCCX(temps[0], temps[1], temps[4]);
                    PhaseCCX(temps[2], temps[3], temps[5]);
                    PhaseCCX(temps[4], temps[5], temps[6]);
                }
                apply {
                    CRz(temps[6], theta, qubit);
                }
            }
            else {
                fail "Too many control qubits specified to Rz gate.";

                // Eventually, we can use recursion via callables with the below utility:
                // ApplyWithLessControlsA(Controlled Rz, (ctls, qubit));
            }
        }
        adjoint (...) {
            Rz(-theta, qubit);
        }
    }

    operation R(pauli : Pauli, theta : Double, qubit : Qubit) : Unit is Adj + Ctl {
        if (pauli == PauliX) {
            Rx(theta, qubit);
        }
        elif (pauli == PauliY) {
            Ry(theta, qubit);
        }
        elif (pauli == PauliZ) {
            Rz(theta, qubit);
        }
        else { // PauliI
            ApplyGlobalPhase(-theta / 2.0 );
        }
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
    operation R1 (theta : Double, qubit : Qubit) : Unit is Adj + Ctl {
        body (...) {
            Rz(theta, qubit);
        }
        controlled (ctls, ...) {
            if Length(ctls) == 0 {
                Rz(theta, qubit);
            }
            elif Length(ctls) == 1 {
                CR1(theta, ctls[0], qubit);
            }
            elif Length(ctls) == 2 {
                use temp = Qubit();
                within {
                    PhaseCCX(ctls[0], ctls[1], temp);
                }
                apply {
                    CR1(theta, temp, qubit);
                }
            }
            elif Length(ctls) == 3 {
                use temps = Qubit[2];
                within {
                    PhaseCCX(ctls[0], ctls[1], temps[0]);
                    PhaseCCX(ctls[2], temps[0], temps[1]);
                }
                apply {
                    CR1(theta, temps[1], qubit);
                }
            }
            elif Length(ctls) == 4 {
                use temps = Qubit[3];
                within {
                    PhaseCCX(ctls[0], ctls[1], temps[0]);
                    PhaseCCX(ctls[2], ctls[3], temps[1]);
                    PhaseCCX(temps[0], temps[1], temps[2]);
                }
                apply {
                    CR1(theta, temps[2], qubit);
                }
            }
            elif Length(ctls) == 5 {
                use temps = Qubit[4];
                within {
                    PhaseCCX(ctls[0], ctls[1], temps[0]);
                    PhaseCCX(ctls[2], ctls[3], temps[1]);
                    PhaseCCX(ctls[4], temps[0], temps[2]);
                    PhaseCCX(temps[1], temps[2], temps[3]);
                }
                apply {
                    CR1(theta, temps[3], qubit);
                }
            }
            elif Length(ctls) == 6 {
                use temps = Qubit[5];
                within {
                    PhaseCCX(ctls[0], ctls[1], temps[0]);
                    PhaseCCX(ctls[2], ctls[3], temps[1]);
                    PhaseCCX(ctls[4], ctls[5], temps[2]);
                    PhaseCCX(temps[0], temps[1], temps[3]);
                    PhaseCCX(temps[2], temps[3], temps[4]);
                }
                apply {
                    CR1(theta, temps[4], qubit);
                }
            }
            elif Length(ctls) == 7 {
                use temps = Qubit[6];
                within {
                    PhaseCCX(ctls[0], ctls[1], temps[0]);
                    PhaseCCX(ctls[2], ctls[3], temps[1]);
                    PhaseCCX(ctls[4], ctls[5], temps[2]);
                    PhaseCCX(ctls[6], temps[0], temps[3]);
                    PhaseCCX(temps[1], temps[2], temps[4]);
                    PhaseCCX(temps[3], temps[4], temps[5]);
                }
                apply {
                    CR1(theta, temps[5], qubit);
                }
            }
            elif Length(ctls) == 8 {
                use temps = Qubit[7];
                within {
                    PhaseCCX(ctls[0], ctls[1], temps[0]);
                    PhaseCCX(ctls[2], ctls[3], temps[1]);
                    PhaseCCX(ctls[4], ctls[5], temps[2]);
                    PhaseCCX(ctls[6], ctls[7], temps[3]);
                    PhaseCCX(temps[0], temps[1], temps[4]);
                    PhaseCCX(temps[2], temps[3], temps[5]);
                    PhaseCCX(temps[4], temps[5], temps[6]);
                }
                apply {
                    CR1(theta, temps[6], qubit);
                }
            }
            else {
                fail "Too many control qubits specified to R1 gate.";
            }
        }

        // R(PauliZ, theta, qubit);
        // R(PauliI, -theta, qubit);
    }

    operation Measure(bases : Pauli[], register : Qubit[]) : Result {
        // If anything is PauliI, strip out and recurse.
        if IsAnyPauliI(bases) {
            return MeasureWithoutPauliI(bases, register);
        }

        // At this point, we're guaranteed that bases contains no PauliI, and
        // has length at least one. The simulator implementation likewise
        // guarantees that in the single-qubit case, the basis is not Z.
        // Let's check the easy single-qubit case first, then, and handle the
        // X and Y cases.
        if Length(bases) == 1 {
            let basis = bases[0];
            let target = register[0];
            mutable result = Zero;
            within {
                if basis == PauliX {
                    Native.H(target);
                } elif basis == PauliY {
                    Native.H(target);
                    Native.S(target);
                } else {
                    // In the PauliZ case, we don't need to do anything here
                    // since Native.M is already in the Z basis by definition.
                }
            } apply {
                set result = Native.M(target);
            }
            return result;
        } else {
            // TODO
            fail "Multi-qubit measurement is not yet implemented.";
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
    operation Exp (paulis : Pauli[], theta : Double, qubits : Qubit[]) : Unit is Adj + Ctl {
        body (...) {
            if (Length(paulis) != Length(qubits)) { fail "Arrays 'pauli' and 'qubits' must have the same length"; }
            let (newPaulis, newQubits) = RemovePauliI(paulis, qubits);

            if (Length(newPaulis) != 0) {
                ExpUtil(newPaulis, theta , newQubits, R(_, -2.0 * theta, _));
            }
            else {
                ApplyGlobalPhase(theta);
            }
        }
        adjoint(...) {
            Exp(paulis, -theta, qubits);
        }
    }

}

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

    // NB: We separate out this operation to avoid hardware targeting rewrite
    //     steps from trying to lift this operation and modifying the C#
    //     code gen in the process.
    //     See https://github.com/microsoft/qsharp-compiler/issues/768.
    internal operation MeasureWithoutPauliI(bases : Pauli[], register : Qubit[]) : Result {
        mutable newBases = [];
        mutable newQubits = [];
        // NB: using Zipped would be nice here, but this is built before
        //     M.Q.Standard...
        for idxBasis in 0..Length(bases) - 1 {
            if bases[idxBasis] != PauliI {
                set newBases += [bases[idxBasis]];
                set newQubits += [register[idxBasis]];
            }
        }

        if Length(newBases) == 0 {
            return Zero;
        } else {
            return Measure(newBases, newQubits);
        }
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

}

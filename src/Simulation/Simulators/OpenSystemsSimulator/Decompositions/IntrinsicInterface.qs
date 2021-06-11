// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

// This namespace contains definitions that parallel each operation in
// M.Q.Intrinsic, making it easier to forward intrinsic definitions from the
// simulator.

namespace Microsoft.Quantum.Experimental.Intrinsic {
    open Microsoft.Quantum.Experimental.Native as Native;
    open Microsoft.Quantum.Experimental.Decompositions;

    internal operation H(target : Qubit) : Unit is Adj + Ctl {
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

    internal operation X(target : Qubit) : Unit is Adj + Ctl {
        body (...) {
            Native.X(target);
        }

        controlled (controls, ...) {
            if Length(controls) == 0 {
                X(target);
            } elif Length(controls) == 1 {
                Native.CNOT(controls[0], target);
            } else {
                fail "Not yet implemented.";
            }
        }
    }

    internal operation Y(target : Qubit) : Unit is Adj + Ctl {
        body (...) {
            Native.Y(target);
        }

        controlled (controls, ...) {
            if Length(controls) == 0 {
                Y(target);
            } elif Length(controls) == 1 {
                within {
                    H(target);
                    S(target);
                } apply {
                    Native.CNOT(controls[0], target);
                }
            } else {
                fail "Not yet implemented.";
            }
        }
    }

    internal operation Z(target : Qubit) : Unit is Adj + Ctl {
        body (...) {
            Native.Z(target);
        }

        controlled (controls, ...) {
            if Length(controls) == 0 {
                Z(target);
            } elif Length(controls) == 1 {
                within {
                    H(target);
                } apply {
                    Native.CNOT(controls[0], target);
                }
            } else {
                fail "Not yet implemented.";
            }
        }
    }

    internal operation S(target : Qubit) : Unit is Adj + Ctl {
        body (...) {
            Native.S(target);
        }

        controlled (controls, ...) {
            fail "Not yet implemented.";
        }
    }

    internal operation T(target : Qubit) : Unit is Adj + Ctl {
        body (...) {
            Native.T(target);
        }

        controlled (controls, ...) {
            fail "Not yet implemented.";
        }
    }

    internal operation Measure(bases : Pauli[], register : Qubit[]) : Result {
        // If anything is PauliI, strip out and recurse.
        if IsAnyPauliI(bases) {
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
                return Measure(newBases, register);
            }
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
                    fail "Single-qubit Z case should have been handled by the simulator.";
                }
            } apply {
                set result = Measure([PauliZ], [target]);
            }
            return result;
        } else {
            // TODO
            fail "Multi-qubit measurement is not yet implemented.";
        }
    }

}

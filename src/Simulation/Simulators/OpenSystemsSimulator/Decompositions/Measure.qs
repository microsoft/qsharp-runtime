// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Experimental.Decompositions {
    open Microsoft.Quantum.Intrinsic as Intrinsic;

    internal function IsAnyPauliI(bases : Pauli[]) : Bool {
        for basis in bases {
            if basis == PauliI {
                return true;
            }
        }
        return false;
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
                    H(target);
                } elif basis == PauliY {
                    H(target);
                    S(target);
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

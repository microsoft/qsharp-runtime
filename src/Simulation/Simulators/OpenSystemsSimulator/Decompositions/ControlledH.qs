// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Experimental.Decompositions {
    open Microsoft.Quantum.Experimental.Native as Native;
    open Microsoft.Quantum.Experimental.Intrinsic as Intrinsic;

    operation PauliZFlip(basis : Pauli, target : Qubit) : Unit
    is Adj {
        if basis == PauliI {
            fail $"PauliX cannot be mapped to PauliI using conjugation by Clifford";
        } elif basis == PauliX {
            Native.H(target);
        } elif basis == PauliY {
            Adjoint Native.S(target);
            Native.H(target);
        } elif basis != PauliZ {
            fail $"PauliZ must be the only remaining case";
        }
    }

    operation Ty(target : Qubit) : Unit
    is Adj {
        within {
            PauliZFlip(PauliY, target);
        } apply {
            Native.T(target);
        }
    }

    operation ApplyControlledH(controls : Qubit[], target : Qubit) : Unit
    is Adj {
        if Length(controls) == 1 {
            within {
                Adjoint Ty(target);
            } apply {
                Controlled Intrinsic.Z([controls[0]], target);
            }
        } else {
            ApplyWithLessControlsA(Controlled Intrinsic.H, (controls, target));
        }
    }

}

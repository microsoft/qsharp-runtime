// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Experimental.Decompositions {
    open Microsoft.Quantum.Intrinsic;

    internal operation PauliZFlip(basis : Pauli, target : Qubit) : Unit
    is Adj {
        if basis == PauliI {
            fail $"PauliX cannot be mapped to PauliI using conjugation by Clifford";
        } elif basis == PauliX {
            H(target);
        } elif basis == PauliY {
            Adjoint S(target);
            Adjoint H(target);
        } elif basis != PauliZ {
            fail $"PauliZ must be the only remaining case";
        }
    }

    internal operation Ty(target : Qubit) : Unit
    is Adj {
        within {
            PauliZFlip(PauliY, target);
        } apply {
            T(target);
        }
    }

    internal operation ApplyControlledH(controls : Qubit[], target : Qubit) : Unit
    is Adj {
        if Length(controls) == 1 {
            within {
                Adjoint Ty(target);
            } apply {
                Controlled Z([controls[0]], target);
            }
        } else {
            ApplyWithLessControlsA(Controlled H, (controls, qubit));
        }
    }

}

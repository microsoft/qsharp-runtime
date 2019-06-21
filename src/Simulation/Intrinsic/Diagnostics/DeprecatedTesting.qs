// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Extensions.Testing {
    open Microsoft.Quantum.Warnings;
    open Microsoft.Quantum.Math;

    /// # Deprecated
    /// Please use @"microsoft.quantum.diagnostics.assertqubit".
    operation AssertQubit(expected : Result, q : Qubit) : Unit {
        _Renamed("Microsoft.Quantum.Extensions.Testing.AssertQubit", "Microsoft.Quantum.Diagnostics.AssertQubit");
        Microsoft.Quantum.Diagnostics.AssertQubit(expected, q);
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.diagnostics.assertqubitwithintolerance".
    operation AssertQubitTol(expected : Result, q : Qubit, tolerance : Double) : Unit {
        _Renamed("Microsoft.Quantum.Extensions.Testing.AssertQubitTol", "Microsoft.Quantum.Diagnostics.AssertQubitWithinTolerance");
        Microsoft.Quantum.Diagnostics.AssertQubitWithinTolerance(expected, q, tolerance);
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.diagnostics.assertqubitisinstatewithintolerance".
    operation AssertQubitState(expected : (Complex, Complex), register : Qubit, tolerance : Double) : Unit {
        _Renamed("Microsoft.Quantum.Extensions.Testing.AssertQubitState", "Microsoft.Quantum.Diagnostics.AssertQubitIsInStateWithinTolerance");
        Microsoft.Quantum.Diagnostics.AssertQubitIsInStateWithinTolerance(expected, register, tolerance);
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.diagnostics.assertoperationsequalreferenced".
    /// Note that the order of the arguments to this operation has changed.
    operation AssertOperationsEqualReferenced(actual : (Qubit[] => Unit), expected : (Qubit[] => Unit : Adjoint), nQubits : Int) : Unit {
        _Renamed("Microsoft.Quantum.Extensions.Testing.AssertOperationsEqualReferenced", "Microsoft.Quantum.Diagnostics.AssertOperationsEqualReferenced");
        Microsoft.Quantum.Diagnostics.AssertOperationsEqualReferenced(nQubits, actual, expected);
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.diagnostics.assertoperationsequalinplace".
    /// Note that the order of the arguments to this operation has changed.
    operation AssertOperationsEqualInPlace(actual : (Qubit[] => Unit), expected : (Qubit[] => Unit : Adjoint), nQubits : Int) : Unit {
        _Renamed("Microsoft.Quantum.Extensions.Testing.AssertOperationsEqualInPlace", "Microsoft.Quantum.Diagnostics.AssertOperationsEqualInPlace");
        Microsoft.Quantum.Diagnostics.AssertOperationsEqualInPlace(nQubits, actual, expected);
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.diagnostics.assertoperationsequalinplaceCompBasis".
    /// Note that the order of the arguments to this operation has changed.
    operation AssertOperationsEqualInPlaceCompBasis(actual : (Qubit[] => Unit), expected : (Qubit[] => Unit : Adjoint), nQubits : Int) : Unit {
        _Renamed("Microsoft.Quantum.Extensions.Testing.AssertOperationsEqualInPlaceCompBasis", "Microsoft.Quantum.Diagnostics.AssertOperationsEqualInPlaceCompBasis");
        Microsoft.Quantum.Diagnostics.AssertOperationsEqualInPlaceCompBasis(nQubits, actual, expected);
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.diagnostics.assertallzero".
    operation AssertAllZero(qubits : Qubit[]) : Unit is Adj + Ctl {
        _Renamed("Microsoft.Quantum.Extensions.Testing.AssertAllZero", "Microsoft.Quantum.Diagnostics.AssertAllZero");
        Microsoft.Quantum.Diagnostics.AssertAllZero(qubits);
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.diagnostics.assertallzerowithintolerance".
    operation AssertAllZeroTol(qubits : Qubit[], tolerance : Double) : Unit is Adj + Ctl {
        _Renamed("Microsoft.Quantum.Extensions.Testing.AssertAllZeroTol", "Microsoft.Quantum.Diagnostics.AssertAllZeroWithinTolerance");
        Microsoft.Quantum.Diagnostics.AssertAllZeroWithinTolerance(qubits, tolerance);
    }

}

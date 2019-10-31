// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Extensions.Testing {
    open Microsoft.Quantum.Math;

    /// # Deprecated
    /// Please use @"microsoft.quantum.diagnostics.assertqubit".
    @Deprecated("Microsoft.Quantum.Diagnostics.AssertQubit")
    operation AssertQubit(expected : Result, q : Qubit) : Unit {
        Microsoft.Quantum.Diagnostics.AssertQubit(expected, q);
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.diagnostics.assertqubitwithintolerance".
    @Deprecated("Microsoft.Quantum.Diagnostics.AssertQubitWithinTolerance")
    operation AssertQubitTol(expected : Result, q : Qubit, tolerance : Double) : Unit {
        Microsoft.Quantum.Diagnostics.AssertQubitWithinTolerance(expected, q, tolerance);
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.diagnostics.assertqubitisinstatewithintolerance".
    @Deprecated("Microsoft.Quantum.Diagnostics.AssertQubitIsInStateWithinTolerance")
    operation AssertQubitState(expected : (Complex, Complex), register : Qubit, tolerance : Double) : Unit {
        Microsoft.Quantum.Diagnostics.AssertQubitIsInStateWithinTolerance(expected, register, tolerance);
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.diagnostics.assertoperationsequalreferenced".
    /// Note that the order of the arguments to this operation has changed.
    @Deprecated("Microsoft.Quantum.Diagnostics.AssertOperationsEqualReferenced")
    operation AssertOperationsEqualReferenced(actual : (Qubit[] => Unit), expected : (Qubit[] => Unit is Adj), nQubits : Int) : Unit {
        Microsoft.Quantum.Diagnostics.AssertOperationsEqualReferenced(nQubits, actual, expected);
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.diagnostics.assertoperationsequalinplace".
    /// Note that the order of the arguments to this operation has changed.
    @Deprecated("Microsoft.Quantum.Diagnostics.AssertOperationsEqualInPlace")
    operation AssertOperationsEqualInPlace(actual : (Qubit[] => Unit), expected : (Qubit[] => Unit is Adj), nQubits : Int) : Unit {
        Microsoft.Quantum.Diagnostics.AssertOperationsEqualInPlace(nQubits, actual, expected);
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.diagnostics.assertoperationsequalinplaceCompBasis".
    /// Note that the order of the arguments to this operation has changed.
    @Deprecated("Microsoft.Quantum.Diagnostics.AssertOperationsEqualInPlaceCompBasis")
    operation AssertOperationsEqualInPlaceCompBasis(actual : (Qubit[] => Unit), expected : (Qubit[] => Unit is Adj), nQubits : Int) : Unit {
        Microsoft.Quantum.Diagnostics.AssertOperationsEqualInPlaceCompBasis(nQubits, actual, expected);
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.diagnostics.assertallzero".
    @Deprecated("Microsoft.Quantum.Diagnostics.AssertAllZero")
    operation AssertAllZero(qubits : Qubit[]) : Unit is Adj + Ctl {
        Microsoft.Quantum.Diagnostics.AssertAllZero(qubits);
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.diagnostics.assertallzerowithintolerance".
    @Deprecated("Microsoft.Quantum.Diagnostics.AssertAllZeroWithinTolerance")
    operation AssertAllZeroTol(qubits : Qubit[], tolerance : Double) : Unit is Adj + Ctl {
        Microsoft.Quantum.Diagnostics.AssertAllZeroWithinTolerance(qubits, tolerance);
    }

}

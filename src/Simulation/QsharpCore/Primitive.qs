// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Primitive {

    /// # Deprecated
    /// Please use @"microsoft.quantum.intrinsic.random".
    @Deprecated("Microsoft.Quantum.Intrinsic.Random")
    operation Random (probs : Double[]) : Int {
        return Microsoft.Quantum.Intrinsic.Random(probs);
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.intrinsic.assert".
    @Deprecated("Microsoft.Quantum.Intrinsic.Assert")
    operation Assert (bases : Pauli[], qubits : Qubit[], result : Result, msg : String) : Unit {
        body (...) {
            Microsoft.Quantum.Intrinsic.Assert(bases, qubits, result, msg);
        }
        adjoint auto;
        controlled auto;
        controlled adjoint auto;
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.intrinsic.assertprob".
    @Deprecated("Microsoft.Quantum.Intrinsic.AssertProb")
    operation AssertProb (bases : Pauli[], qubits : Qubit[], result : Result, prob : Double, msg : String, tol : Double) : Unit
    {
        body (...) {
            Microsoft.Quantum.Intrinsic.AssertProb(bases, qubits, result, prob, msg, tol);
        }
        adjoint auto;
        controlled auto;
        controlled adjoint auto;
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.intrinsic.message".
    @Deprecated("Microsoft.Quantum.Intrinsic.Message")
    function Message (msg : String) : Unit {
        return Microsoft.Quantum.Intrinsic.Message(msg);
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.intrinsic.i".
    @Deprecated("Microsoft.Quantum.Intrinsic.I")
    operation I (qubit : Qubit) : Unit {
        body (...) {
            Microsoft.Quantum.Intrinsic.I(qubit);
        }
        adjoint self;
        controlled auto;
        controlled adjoint self;
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.intrinsic.x".
    @Deprecated("Microsoft.Quantum.Intrinsic.X")
    operation X (qubit : Qubit) : Unit {
        body (...) {
            Microsoft.Quantum.Intrinsic.X(qubit);
        }
        adjoint self;
        controlled auto;
        controlled adjoint self;
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.intrinsic.y".
    @Deprecated("Microsoft.Quantum.Intrinsic.Y")
    operation Y (qubit : Qubit) : Unit {
        body (...) {
            Microsoft.Quantum.Intrinsic.Y(qubit);
        }
        adjoint self;
        controlled auto;
        controlled adjoint self;
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.intrinsic.z".
    @Deprecated("Microsoft.Quantum.Intrinsic.Z")
    operation Z (qubit : Qubit) : Unit {
        body (...) {
            Microsoft.Quantum.Intrinsic.Z(qubit);
        }
        adjoint self;
        controlled auto;
        controlled adjoint self;
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.intrinsic.h".
    @Deprecated("Microsoft.Quantum.Intrinsic.H")
    operation H (qubit : Qubit) : Unit {
        body (...) {
            Microsoft.Quantum.Intrinsic.H(qubit);
        }
        adjoint self;
        controlled auto;
        controlled adjoint self;
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.intrinsic.s".
    @Deprecated("Microsoft.Quantum.Intrinsic.S")
    operation S (qubit : Qubit) : Unit {
        body (...) {
            Microsoft.Quantum.Intrinsic.S(qubit);
        }
        adjoint auto;
        controlled auto;
        controlled adjoint auto;
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.intrinsic.t".
    @Deprecated("Microsoft.Quantum.Intrinsic.T")
    operation T (qubit : Qubit) : Unit {
        body (...) {
            Microsoft.Quantum.Intrinsic.T(qubit);
        }
        adjoint auto;
        controlled auto;
        controlled adjoint auto;
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.intrinsic.cnot".
    @Deprecated("Microsoft.Quantum.Intrinsic.CNOT")
    operation CNOT (control : Qubit, target : Qubit) : Unit {
        body (...) {
            Microsoft.Quantum.Intrinsic.CNOT(control, target);
        }

        adjoint auto;
        controlled auto;
        controlled adjoint auto;
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.intrinsic.ccnot".
    @Deprecated("Microsoft.Quantum.Intrinsic.CCNOT")
    operation CCNOT (control1 : Qubit, control2 : Qubit, target : Qubit) : Unit {
        body (...) {
            Microsoft.Quantum.Intrinsic.CCNOT(control1, control2, target);
        }

        adjoint auto;
        controlled auto;
        controlled adjoint auto;
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.intrinsic.swap".
    @Deprecated("Microsoft.Quantum.Intrinsic.SWAP")
    operation SWAP (qubit1 : Qubit, qubit2 : Qubit) : Unit {
        body (...) {
            Microsoft.Quantum.Intrinsic.SWAP(qubit1, qubit2);
        }

        adjoint auto;
        controlled auto;
        controlled adjoint auto;
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.canon.applytoeachca".
    @Deprecated("ApplyToEachCA(X, _)")
    operation MultiX (qubits : Qubit[]) : Unit {
        body (...) {
            for (index in 0 .. Length(qubits) - 1) {
                Microsoft.Quantum.Intrinsic.X(qubits[index]);
            }
        }

        adjoint self;
        controlled distribute;
        controlled adjoint self;
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.intrinsic.r".
    @Deprecated("Microsoft.Quantum.Intrinsic.R")
    operation R(pauli : Pauli, theta : Double, qubit : Qubit) : Unit {
        body (...) {
            Microsoft.Quantum.Intrinsic.R(pauli, theta, qubit);
        }
        adjoint auto;
        controlled auto;
        controlled adjoint auto;
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.intrinsic.rfrac".
    @Deprecated("Microsoft.Quantum.Intrinsic.RFrac")
    operation RFrac(pauli : Pauli, numerator : Int, power : Int, qubit : Qubit) : Unit {
        body (...) {
            Microsoft.Quantum.Intrinsic.RFrac(pauli, numerator, power, qubit);
        }
        
        adjoint auto;
        controlled auto;
        controlled adjoint auto;
    }
    
    
    /// # Deprecated
    /// Please use @"microsoft.quantum.intrinsic.rx".
    @Deprecated("Microsoft.Quantum.Intrinsic.Rx")
    operation Rx (theta : Double, qubit : Qubit) : Unit {
        body (...) {
            Microsoft.Quantum.Intrinsic.Rx(theta, qubit);
        }
        
        adjoint auto;
        controlled auto;
        controlled adjoint auto;
    }
    
    /// # Deprecated
    /// Please use @"microsoft.quantum.intrinsic.ry".
    @Deprecated("Microsoft.Quantum.Intrinsic.Ry")
    operation Ry (theta : Double, qubit : Qubit) : Unit {
        body (...) {
            Microsoft.Quantum.Intrinsic.Ry(theta, qubit);
        }
        
        adjoint auto;
        controlled auto;
        controlled adjoint auto;
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.intrinsic.rz".
    @Deprecated("Microsoft.Quantum.Intrinsic.Rz")
    operation Rz (theta : Double, qubit : Qubit) : Unit {
        body (...) {
            Microsoft.Quantum.Intrinsic.Rz(theta, qubit);
        }
        
        adjoint auto;
        controlled auto;
        controlled adjoint auto;
    }
    
    /// # Deprecated
    /// Please use @"microsoft.quantum.intrinsic.r1".
    @Deprecated("Microsoft.Quantum.Intrinsic.R1")
    operation R1 (theta : Double, qubit : Qubit) : Unit
    {
        body (...) {
            Microsoft.Quantum.Intrinsic.R1(theta, qubit);
        }
        
        adjoint auto;
        controlled auto;
        controlled adjoint auto;
    }
    
    /// # Deprecated
    /// Please use @"microsoft.quantum.intrinsic.r1frac".
    @Deprecated("Microsoft.Quantum.Intrinsic.R1Frac")
    operation R1Frac (numerator : Int, power : Int, qubit : Qubit) : Unit
    {
        body (...) {
            Microsoft.Quantum.Intrinsic.R1Frac(numerator, power, qubit);
        }
        
        adjoint auto;
        controlled auto;
        controlled adjoint auto;
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.intrinsic.exp".
    @Deprecated("Microsoft.Quantum.Intrinsic.Exp")
    operation Exp (paulis : Pauli[], theta : Double, qubits : Qubit[]) : Unit {
        body (...) {
            Microsoft.Quantum.Intrinsic.Exp(paulis, theta, qubits);
        }
        adjoint auto;
        controlled auto;
        controlled adjoint auto;
    }
    
    /// # Deprecated
    /// Please use @"microsoft.quantum.intrinsic.expfrac".
    @Deprecated("Microsoft.Quantum.Intrinsic.ExpFrac")
    operation ExpFrac (paulis : Pauli[], numerator : Int, power : Int, qubits : Qubit[]) : Unit {
        body (...) {
            Microsoft.Quantum.Intrinsic.ExpFrac(paulis, numerator, power, qubits);
        }
        adjoint auto;
        controlled auto;
        controlled adjoint auto;
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.intrinsic.measure".
    @Deprecated("Microsoft.Quantum.Intrinsic.Measure")
    operation Measure(bases : Pauli[], qubits : Qubit[]) : Result {
        return Microsoft.Quantum.Intrinsic.Measure(bases, qubits);
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.intrinsic.m".
    @Deprecated("Microsoft.Quantum.Intrinsic.M")
    operation M (qubit : Qubit) : Result {
        return Microsoft.Quantum.Intrinsic.M(qubit);
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.intrinsic.reset".
    @Deprecated("Microsoft.Quantum.Intrinsic.Reset")
    operation Reset (target : Qubit) : Unit {
        return Microsoft.Quantum.Intrinsic.Reset(target);
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.intrinsic.resetall".
    @Deprecated("Microsoft.Quantum.Intrinsic.ResetAll")
    operation ResetAll (qubits : Qubit[]) : Unit {
        return Microsoft.Quantum.Intrinsic.ResetAll(qubits);
    }

}


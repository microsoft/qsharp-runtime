// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Primitive {
    open Microsoft.Quantum.Warnings;

    /// # Deprecated
    /// Please use @"microsoft.quantum.intrinsic.random".
    operation Random (probs : Double[]) : Int {
        _Renamed("Microsoft.Quantum.Primitive.Random", "Microsoft.Quantum.Intrinsic.Random");
        return Microsoft.Quantum.Intrinsic.Random(probs);
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.intrinsic.assert".
    operation Assert (bases : Pauli[], qubits : Qubit[], result : Result, msg : String) : Unit {
        body (...) {
            _Renamed("Microsoft.Quantum.Primitive.Assert", "Microsoft.Quantum.Intrinsic.Assert");
            Microsoft.Quantum.Intrinsic.Assert(bases, qubits, result, msg);
        }
        adjoint auto;
        controlled auto;
        controlled adjoint auto;
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.intrinsic.assertprob".
    operation AssertProb (bases : Pauli[], qubits : Qubit[], result : Result, prob : Double, msg : String, tol : Double) : Unit
    {
        body (...) {
            _Renamed("Microsoft.Quantum.Primitive.AssertProb", "Microsoft.Quantum.Intrinsic.AssertProb");
            Microsoft.Quantum.Intrinsic.AssertProb(bases, qubits, result, prob, msg, tol);
        }
        adjoint auto;
        controlled auto;
        controlled adjoint auto;
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.intrinsic.message".
    function Message (msg : String) : Unit {
        _Renamed("Microsoft.Quantum.Primitive.Message", "Microsoft.Quantum.Intrinsic.Message");
        return Microsoft.Quantum.Intrinsic.Message(msg);
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.intrinsic.i".
    operation I (qubit : Qubit) : Unit {
        body (...) {
            _Renamed("Microsoft.Quantum.Primitive.I", "Microsoft.Quantum.Intrinsic.I");
            Microsoft.Quantum.Intrinsic.I(qubit);
        }
        adjoint self;
        controlled auto;
        controlled adjoint self;
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.intrinsic.x".
    operation X (qubit : Qubit) : Unit {
        body (...) {
            _Renamed("Microsoft.Quantum.Primitive.X", "Microsoft.Quantum.Intrinsic.X");
            Microsoft.Quantum.Intrinsic.X(qubit);
        }
        adjoint self;
        controlled auto;
        controlled adjoint self;
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.intrinsic.y".
    operation Y (qubit : Qubit) : Unit {
        body (...) {
            _Renamed("Microsoft.Quantum.Primitive.Y", "Microsoft.Quantum.Intrinsic.Y");
            Microsoft.Quantum.Intrinsic.Y(qubit);
        }
        adjoint self;
        controlled auto;
        controlled adjoint self;
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.intrinsic.z".
    operation Z (qubit : Qubit) : Unit {
        body (...) {
            _Renamed("Microsoft.Quantum.Primitive.Z", "Microsoft.Quantum.Intrinsic.Z");
            Microsoft.Quantum.Intrinsic.Z(qubit);
        }
        adjoint self;
        controlled auto;
        controlled adjoint self;
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.intrinsic.h".
    operation H (qubit : Qubit) : Unit {
        body (...) {
            _Renamed("Microsoft.Quantum.Primitive.H", "Microsoft.Quantum.Intrinsic.H");
            Microsoft.Quantum.Intrinsic.H(qubit);
        }
        adjoint self;
        controlled auto;
        controlled adjoint self;
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.intrinsic.s".
    operation S (qubit : Qubit) : Unit {
        body (...) {
            _Renamed("Microsoft.Quantum.Primitive.S", "Microsoft.Quantum.Intrinsic.S");
            Microsoft.Quantum.Intrinsic.S(qubit);
        }
        adjoint auto;
        controlled auto;
        controlled adjoint auto;
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.intrinsic.t".
    operation T (qubit : Qubit) : Unit {
        body (...) {
            _Renamed("Microsoft.Quantum.Primitive.T", "Microsoft.Quantum.Intrinsic.T");
            Microsoft.Quantum.Intrinsic.T(qubit);
        }
        adjoint auto;
        controlled auto;
        controlled adjoint auto;
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.intrinsic.cnot".
    operation CNOT (control : Qubit, target : Qubit) : Unit {
        body (...) {
            _Renamed("Microsoft.Quantum.Primitive.CNOT", "Microsoft.Quantum.Intrinsic.CNOT");
            Microsoft.Quantum.Intrinsic.CNOT(control, target);
        }

        adjoint auto;
        controlled auto;
        controlled adjoint auto;
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.intrinsic.ccnot".
    operation CCNOT (control1 : Qubit, control2 : Qubit, target : Qubit) : Unit {
        body (...) {
            _Renamed("Microsoft.Quantum.Primitive.CCNOT", "Microsoft.Quantum.Intrinsic.CCNOT");
            Microsoft.Quantum.Intrinsic.CCNOT(control1, control2, target);
        }

        adjoint auto;
        controlled auto;
        controlled adjoint auto;
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.intrinsic.swap".
    operation SWAP (qubit1 : Qubit, qubit2 : Qubit) : Unit {
        body (...) {
            _Renamed("Microsoft.Quantum.Primitive.SWAP", "Microsoft.Quantum.Intrinsic.SWAP");
            Microsoft.Quantum.Intrinsic.SWAP(qubit1, qubit2);
        }

        adjoint auto;
        controlled auto;
        controlled adjoint auto;
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.canon.applytoeachca".
    operation MultiX (qubits : Qubit[]) : Unit {
        body (...) {
            _Removed("Microsoft.Quantum.Primitive.MultiX", "ApplyToEachCA(X, _)");
            for (index in 0 .. Length(qubits) - 1) {
                X(qubits[index]);
            }
        }

        adjoint self;
        controlled distribute;
        controlled adjoint self;
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.intrinsic.r".
    operation R(pauli : Pauli, theta : Double, qubit : Qubit) : Unit {
        body (...) {
            _Renamed("Microsoft.Quantum.Primitive.R", "Microsoft.Quantum.Intrinsic.R");
            Microsoft.Quantum.Intrinsic.R(pauli, theta, qubit);
        }
        adjoint auto;
        controlled auto;
        controlled adjoint auto;
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.intrinsic.rfrac".
    operation RFrac(pauli : Pauli, numerator : Int, power : Int, qubit : Qubit) : Unit {
        body (...) {
            _Renamed("Microsoft.Quantum.Primitive.RFrac", "Microsoft.Quantum.Intrinsic.RFrac");
            Microsoft.Quantum.Intrinsic.RFrac(pauli, numerator, power, qubit);
        }
        
        adjoint auto;
        controlled auto;
        controlled adjoint auto;
    }
    
    
    /// # Deprecated
    /// Please use @"microsoft.quantum.intrinsic.rx".
    operation Rx (theta : Double, qubit : Qubit) : Unit {
        body (...) {
            _Renamed("Microsoft.Quantum.Primitive.Rx", "Microsoft.Quantum.Intrinsic.Rx");
            Microsoft.Quantum.Intrinsic.Rx(theta, qubit);
        }
        
        adjoint auto;
        controlled auto;
        controlled adjoint auto;
    }
    
    /// # Deprecated
    /// Please use @"microsoft.quantum.intrinsic.ry".
    operation Ry (theta : Double, qubit : Qubit) : Unit {
        body (...) {
            _Renamed("Microsoft.Quantum.Primitive.Ry", "Microsoft.Quantum.Intrinsic.Ry");
            Microsoft.Quantum.Intrinsic.Ry(theta, qubit);
        }
        
        adjoint auto;
        controlled auto;
        controlled adjoint auto;
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.intrinsic.rz".
    operation Rz (theta : Double, qubit : Qubit) : Unit {
        body (...) {
            _Renamed("Microsoft.Quantum.Primitive.Rz", "Microsoft.Quantum.Intrinsic.Rz");
            Microsoft.Quantum.Intrinsic.Rz(theta, qubit);
        }
        
        adjoint auto;
        controlled auto;
        controlled adjoint auto;
    }
    
    /// # Deprecated
    /// Please use @"microsoft.quantum.intrinsic.r1".
    operation R1 (theta : Double, qubit : Qubit) : Unit
    {
        body (...) {
            _Renamed("Microsoft.Quantum.Primitive.R1", "Microsoft.Quantum.Intrinsic.R1");
            Microsoft.Quantum.Intrinsic.R1(theta, qubit);
        }
        
        adjoint auto;
        controlled auto;
        controlled adjoint auto;
    }
    
    /// # Deprecated
    /// Please use @"microsoft.quantum.intrinsic.r1frac".
    operation R1Frac (numerator : Int, power : Int, qubit : Qubit) : Unit
    {
        body (...) {
            _Renamed("Microsoft.Quantum.Primitive.R1Frac", "Microsoft.Quantum.Intrinsic.R1Frac");
            Microsoft.Quantum.Intrinsic.R1Frac(numerator, power, qubit);
        }
        
        adjoint auto;
        controlled auto;
        controlled adjoint auto;
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.intrinsic.exp".
    operation Exp (paulis : Pauli[], theta : Double, qubits : Qubit[]) : Unit {
        body (...) {
            _Renamed("Microsoft.Quantum.Primitive.Exp", "Microsoft.Quantum.Intrinsic.Exp");
            Microsoft.Quantum.Intrinsic.Exp(paulis, theta, qubits);
        }
        adjoint auto;
        controlled auto;
        controlled adjoint auto;
    }
    
    /// # Deprecated
    /// Please use @"microsoft.quantum.intrinsic.expfrac".
    operation ExpFrac (paulis : Pauli[], numerator : Int, power : Int, qubits : Qubit[]) : Unit {
        body (...) {
            _Renamed("Microsoft.Quantum.Primitive.ExpFrac", "Microsoft.Quantum.Intrinsic.ExpFrac");
            Microsoft.Quantum.Intrinsic.ExpFrac(paulis, numerator, power, qubits);
        }
        adjoint auto;
        controlled auto;
        controlled adjoint auto;
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.intrinsic.measure".
    operation Measure(bases : Pauli[], qubits : Qubit[]) : Result {
        _Renamed("Microsoft.Quantum.Primitive.Measure", "Microsoft.Quantum.Intrinsic.Measure");
        return Microsoft.Quantum.Intrinsic.Measure(bases, qubits);
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.intrinsic.m".
    operation M (qubit : Qubit) : Result {
        _Renamed("Microsoft.Quantum.Primitive.M", "Microsoft.Quantum.Intrinsic.M");
        return Microsoft.Quantum.Intrinsic.M(qubit);
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.intrinsic.reset".
    operation Reset (target : Qubit) : Unit {
        _Renamed("Microsoft.Quantum.Primitive.Reset", "Microsoft.Quantum.Intrinsic.Reset");
        return Microsoft.Quantum.Intrinsic.Reset(target);
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.intrinsic.resetall".
    operation ResetAll (qubits : Qubit[]) : Unit {
        _Renamed("Microsoft.Quantum.Primitive.ResetAll", "Microsoft.Quantum.Intrinsic.ResetAll");
        return Microsoft.Quantum.Intrinsic.ResetAll(qubits);
    }

}


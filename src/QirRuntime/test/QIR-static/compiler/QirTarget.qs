// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Intrinsic {

    open Microsoft.Quantum.Targeting;

    @Inline()
    function NAN() : Double {
        body intrinsic;
    }

    @Inline()
    function IsNan(d: Double) : Bool {
        body intrinsic;
    }

    @Inline()
    function INFINITY() : Double {
        body intrinsic;
    }

    @Inline()
    function IsInf(d: Double) : Bool {
        body intrinsic;
    }

    @Inline()
    function IsNegativeInfinity(d : Double) : Bool {
        body intrinsic;
    }

    @Inline()
    function Sqrt(d : Double) : Double {
        body intrinsic;
    }

    @Inline()
    function Log(d : Double) : Double {
        body intrinsic;
    }

    @Inline()
    function ArcTan2(y : Double, x : Double) : Double {
        body intrinsic;
    }


    operation X(qb : Qubit) : Unit
    is Adj + Ctl {
        body intrinsic;
        adjoint self;
    }

    operation Y(qb : Qubit) : Unit
    is Adj + Ctl {
        body intrinsic;
        adjoint self;
    }

    operation Z(qb : Qubit) : Unit
    is Adj + Ctl {
        body intrinsic;
        adjoint self;
    }

    operation H(qb : Qubit) : Unit
    is Adj + Ctl {
        body intrinsic;
        adjoint self;
    }

    operation S(qb : Qubit) : Unit
    is Adj + Ctl {
        body intrinsic;
    }

    operation T(qb : Qubit) : Unit
    is Adj + Ctl {
        body intrinsic;
    }

    operation R (pauli : Pauli, theta : Double, qubit : Qubit) : Unit
    is Adj + Ctl
    {
        body intrinsic;
    }

    operation Exp (paulis : Pauli[], theta : Double, qubits : Qubit[]) : Unit
    is Adj + Ctl
    {
        body intrinsic;
    }

    operation Measure(bases : Pauli[], qubits : Qubit[]) : Result {
        body intrinsic;
    }

    operation M(qb : Qubit) : Result {
        body (...) {
            return Measure([PauliZ], [qb]);
        }
    }
}

// Handling of conditionals
namespace Microsoft.Quantum.Canon
{
    operation NoOp<'T> (input : 'T) : Unit is Adj + Ctl {}
}

namespace Microsoft.Quantum.Simulation.QuantumProcessor.Extensions
{
    operation ApplyIfZero<'T> (result : Result, (op : ('T => Unit), target : 'T)) : Unit {
        body intrinsic;
    }
    operation ApplyIfZeroA<'T> (result : Result, (op : ('T => Unit is Adj), target : 'T)) : Unit is Adj {
        body intrinsic;
    }
    operation ApplyIfZeroC<'T> (result : Result, (op : ('T => Unit is Ctl), target : 'T)) : Unit is Ctl {
        body intrinsic;
    }
    operation ApplyIfZeroCA<'T> (result : Result, (op : ('T => Unit is Adj + Ctl), target : 'T)) : Unit is Adj + Ctl {
        body intrinsic;
    }
    operation ApplyIfOne<'T> (result : Result, (op : ('T => Unit), target : 'T)) : Unit {
        body intrinsic;
    }
    operation ApplyIfOneA<'T> (result : Result, (op : ('T => Unit is Adj), target : 'T)) : Unit is Adj {
        body intrinsic;
    }
    operation ApplyIfOneC<'T> (result : Result, (op : ('T => Unit is Ctl), target : 'T)) : Unit is Ctl {
        body intrinsic;
    }
    operation ApplyIfOneCA<'T> (result : Result, (op : ('T => Unit is Adj + Ctl), target : 'T)) : Unit is Adj + Ctl {
        body intrinsic;
    }
    operation ApplyIfElseR<'T, 'U> (
        result : Result, 
        (zeroOp : ('T => Unit), zeroInput : 'T), (oneOp : ('U => Unit), oneInput : 'U)) : Unit {
        body intrinsic;
    }
    operation ApplyIfElseRA<'T, 'U> (
        result : Result, 
        (zeroOp : ('T => Unit is Adj), zeroInput : 'T), (oneOp : ('U => Unit is Adj), oneInput : 'U)) : Unit is Adj {
        body intrinsic;
    }
    operation ApplyIfElseRC<'T, 'U> (
        result : Result, 
        (zeroOp : ('T => Unit is Ctl), zeroInput : 'T), (oneOp : ('U => Unit is Ctl), oneInput : 'U)) : Unit is Ctl {
        body intrinsic;
    }
    operation ApplyIfElseRCA<'T, 'U> (
        result : Result, 
        (zeroOp : ('T => Unit is Adj + Ctl), zeroInput : 'T), (oneOp : ('U => Unit is Adj + Ctl), oneInput : 'U)) : Unit is Adj + Ctl {
        body intrinsic;
    }
}

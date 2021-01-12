// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Instructions {

    open Microsoft.Quantum.Targeting;

    @TargetInstruction("single_qubit_op")
    operation single_qubit_op (op_id: Int, duration: Int, qb : Qubit) : Unit {
        body intrinsic;
    }

    @TargetInstruction("multi_qubit_op")
    operation multi_qubit_op (op_id: Int, duration: Int, qbs : Qubit[]) : Unit {
        body intrinsic;
    }

    @TargetInstruction("single_qubit_op_ctl")
    operation single_qubit_op_ctl (op_id: Int, duration: Int, ctl : Qubit[], qb : Qubit) : Unit {
        body intrinsic;
    }

    @TargetInstruction("multi_qubit_op_ctl")
    operation multi_qubit_op_ctl (op_id: Int, duration: Int, ctl : Qubit[], qbs : Qubit[]) : Unit {
        body intrinsic;
    }
}


namespace Microsoft.Quantum.Intrinsic {

    open Microsoft.Quantum.Core;
    open Microsoft.Quantum.Instructions as Phys;

    @Inline()
    operation X(qb : Qubit) : Unit
    is Adj + Ctl {
        body  (...) { Phys.single_qubit_op(0, 1, qb); }
        adjoint (...) { Phys.single_qubit_op(0, 1, qb); }
        controlled (ctls, ...)
        {
            if (Length(ctls) == 1) { Phys.single_qubit_op_ctl(1, 1, ctls, qb); }
            else { Phys.single_qubit_op_ctl(2, 1, ctls, qb); }
        }
        controlled adjoint (ctls, ...)
        {
            if (Length(ctls) == 1) { Phys.single_qubit_op_ctl(1, 1, ctls, qb); }
            else { Phys.single_qubit_op_ctl(2, 1, ctls, qb); }
        }
    }

    operation CNOT(control : Qubit, target : Qubit) : Unit
    is Adj {
        body  (...) { Controlled X([control], target); }
        adjoint (...) { Controlled X([control], target); }
    }

    @Inline()
    operation Y(qb : Qubit) : Unit
    is Adj + Ctl{
        body  (...) { Phys.single_qubit_op(3, 1, qb); }
        adjoint (...) { Phys.single_qubit_op(3, 1, qb); }
        controlled (ctls, ...)
        {
            if (Length(ctls) == 1) { Phys.single_qubit_op_ctl(4, 1, ctls, qb); }
            else { Phys.single_qubit_op_ctl(5, 1, ctls, qb); }
        }
        controlled adjoint (ctls, ...)
        {
            if (Length(ctls) == 1) { Phys.single_qubit_op_ctl(4, 1, ctls, qb); }
            else { Phys.single_qubit_op_ctl(5, 1, ctls, qb); }
        }
    }

    @Inline()
    operation Z(qb : Qubit) : Unit
    is Adj + Ctl {
        body  (...) { Phys.single_qubit_op(6, 1, qb); }
        adjoint (...) { Phys.single_qubit_op(6, 1, qb); }
        controlled (ctls, ...)
        {
            if (Length(ctls) == 1) { Phys.single_qubit_op_ctl(7, 1, ctls, qb); }
            else { Phys.single_qubit_op_ctl(8, 1, ctls, qb); }
        }
        controlled adjoint (ctls, ...)
        {
            if (Length(ctls) == 1) { Phys.single_qubit_op_ctl(7, 1, ctls, qb); }
            else { Phys.single_qubit_op_ctl(8, 1, ctls, qb); }
        }
    }

    @Inline()
    operation H(qb : Qubit) : Unit
    is Adj + Ctl {
        body  (...) { Phys.single_qubit_op(9, 1, qb); }
        adjoint (...) { Phys.single_qubit_op(9, 1, qb); }
        controlled (ctls, ...)
        {
            Phys.single_qubit_op_ctl(10, 1, ctls, qb);
        }
        controlled adjoint (ctls, ...)
        {
            Phys.single_qubit_op_ctl(10, 1, ctls, qb);
        }
    }

    @Inline()
    operation Tz(qb : Qubit) : Unit
    is Adj + Ctl {
        body  (...) { Phys.single_qubit_op(11, 1, qb); }
        adjoint (...) { Phys.single_qubit_op(11, 1, qb); }
        controlled (ctls, ...)
        {
            Phys.single_qubit_op_ctl(12, 1, ctls, qb);
        }
        controlled adjoint (ctls, ...)
        {
            Phys.single_qubit_op_ctl(12, 1, ctls, qb);
        }
    }

    @Inline()
    operation Tx(qb : Qubit) : Unit
    is Adj + Ctl {
        body  (...) { Phys.single_qubit_op(13, 1, qb); }
        adjoint (...) { Phys.single_qubit_op(13, 1, qb); }
        controlled (ctls, ...)
        {
            Phys.single_qubit_op_ctl(14, 1, ctls, qb);
        }
        controlled adjoint (ctls, ...)
        {
            Phys.single_qubit_op_ctl(14, 1, ctls, qb);
        }
    }

    @Inline()
    operation T(qb : Qubit) : Unit
    is Adj + Ctl {
        body  (...) { Tz(qb); }
        adjoint (...) { Tz(qb); }
        controlled (ctls, ...) { Controlled Tz(ctls, qb); }
        controlled adjoint (ctls, ...) { Controlled Adjoint Tz(ctls, qb); }
    }

    @Inline()
    operation Sz(qb : Qubit) : Unit
    is Adj + Ctl {
        body  (...) { Phys.single_qubit_op(15, 1, qb); }
        adjoint (...) { Phys.single_qubit_op(15, 1, qb); }
        controlled (ctls, ...) { Phys.single_qubit_op_ctl(16, 1, ctls, qb); }
        controlled adjoint (ctls, ...) { Phys.single_qubit_op_ctl(16, 1, ctls, qb); }
    }

    @Inline()
    operation Sx(qb : Qubit) : Unit
    is Adj + Ctl {
        body  (...) { Phys.single_qubit_op(17, 1, qb); }
        adjoint (...) { Phys.single_qubit_op(17, 1, qb); }
        controlled (ctls, ...) { Phys.single_qubit_op_ctl(18, 1, ctls, qb); }
        controlled adjoint (ctls, ...) { Phys.single_qubit_op_ctl(18, 1, ctls, qb); }
    }

    @Inline()
    operation S(qb : Qubit) : Unit
    is Adj + Ctl {
        body  (...) { Sz(qb); }
        adjoint (...) { Sz(qb); }
        controlled (ctls, ...) { Controlled Sz(ctls, qb); }
        controlled adjoint (ctls, ...) { Controlled Adjoint Sz(ctls, qb); }
    }

    @Inline()
    operation Rx(theta : Double, qb : Qubit) : Unit
    is Adj + Ctl {
        body  (...) { Phys.single_qubit_op(19, 1, qb); }
        adjoint (...) { Phys.single_qubit_op(19, 1, qb); }
        controlled (ctls, ...) { Phys.single_qubit_op_ctl(20, 1, ctls, qb); }
        controlled adjoint (ctls, ...) { Phys.single_qubit_op_ctl(20, 1, ctls, qb); }
    }

    @Inline()
    operation Ry(theta : Double, qb : Qubit) : Unit
    is Adj + Ctl {
        body  (...) { Phys.single_qubit_op(21, 1, qb); }
        adjoint (...) { Phys.single_qubit_op(21, 1, qb); }
        controlled (ctls, ...) { Phys.single_qubit_op_ctl(22, 1, ctls, qb); }
        controlled adjoint (ctls, ...) { Phys.single_qubit_op_ctl(22, 1, ctls, qb); }
    }

    @Inline()
    operation Rz(theta : Double, qb : Qubit) : Unit
    is Adj + Ctl {
        body  (...) { Phys.single_qubit_op(23, 1, qb); }
        adjoint (...) { Phys.single_qubit_op(24, 1, qb); }
        controlled (ctls, ...) { Phys.single_qubit_op_ctl(25, 1, ctls, qb); }
        controlled adjoint (ctls, ...) { Phys.single_qubit_op_ctl(25, 1, ctls, qb); }
    }

    @TargetInstruction("inject_global_barrier")
    operation Barrier(name : String, duration : Int) : Unit
    {
        body intrinsic;
    }

    operation SWAP(a : Qubit, b : Qubit) : Unit 
    is Adj {
        body intrinsic;
        adjoint self;
    }

    operation M(qb : Qubit) : Result {
        body intrinsic;
    }

    operation Measure(bases : Pauli[], qubits : Qubit[]) : Result {
        body intrinsic;
    }

}

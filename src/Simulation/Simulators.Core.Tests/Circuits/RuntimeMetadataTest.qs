// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.Simulators.Tests.Circuits {

    open Microsoft.Quantum.Intrinsic;

    newtype FooUDT = (String, (Qubit, Double));

    operation FooUDTOp (foo : FooUDT) : Unit is Ctl + Adj { }

    operation Empty () : Unit is Ctl + Adj { }

    operation WrapperOp (op: (Qubit => Unit), q : Qubit) : Unit {
        op(q);
        Reset(q);
    }

    operation HOp (q : Qubit) : Unit {
        H(q);
        Reset(q);
    }

    operation NestedOp () : Unit {
        using (q = Qubit()) {
            HOp(q);
        }
    }

    operation TwoQubitOp (q1 : Qubit, q2 : Qubit) : Unit {
        // ...
    }

    operation BoolArrayOp (bits : Bool[]) : Unit {
        // ...
    }
    
}

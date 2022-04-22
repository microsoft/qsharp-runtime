namespace Reference {
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Diagnostics;

    // These intrinsic operations will get generated into concrete C# wrappers over the same
    // interfaces as those implemented by the full state simulator, allowing them to be used
    // as references for validating alternate decompositions.

    operation H(qubit : Qubit) : Unit is Adj + Ctl {
        body intrinsic;
        adjoint self;
    }

    operation S(qubit : Qubit) : Unit is Adj + Ctl {
        body intrinsic;
    }

    operation T(qubit : Qubit) : Unit is Adj + Ctl {
        body intrinsic;
    }

    operation X(qubit : Qubit) : Unit is Adj + Ctl {
        body intrinsic;
        adjoint self;
    }

    operation Y(qubit : Qubit) : Unit is Adj + Ctl {
        body intrinsic;
        adjoint self;
    }

    operation Z(qubit : Qubit) : Unit is Adj + Ctl {
        body intrinsic;
        adjoint self;
    }

    operation R(pauli : Pauli, theta : Double, qubit : Qubit) : Unit is Adj + Ctl {
        body intrinsic;
    }

    operation Reset(qubit : Qubit) : Unit {
        body intrinsic;
    }

    // Use the trivial decomposition of SWAP to emulate an intrinsic SWAP on the simulator.
    operation SWAP(qubit1 : Qubit, qubit2 : Qubit) : Unit is Adj + Ctl {
        Controlled X([qubit1], qubit2);
        Controlled X([qubit2], qubit1);
        Controlled X([qubit1], qubit2);
    }

    // Use the trivial decomposition of R1 to emulate intrinsic R1 on the simulator.
    operation R1 (theta : Double, qubit : Qubit) : Unit is Adj + Ctl {
        R(PauliZ, theta, qubit);
        R(PauliI, -theta, qubit);
    }

    // The following operations are reproduced here to ensure that `AssertOperationsEqualReferenced`
    // uses these reference implementations for preparation and evaluation instead of the decompositions
    // under test.

    internal operation ResetAll (qubits : Qubit[]) : Unit {
        for qubit in qubits {
            Reset(qubit);
        }
    }

    internal operation PrepareEntangledState (left : Qubit[], right : Qubit[]) : Unit
    is Adj + Ctl {

        for idxQubit in 0 .. Length(left) - 1
        {
            H(left[idxQubit]);
            Controlled X([left[idxQubit]], right[idxQubit]);
        }
    }

    operation AssertOperationsEqualReferenced (nQubits : Int, actual : (Qubit[] => Unit), expected : (Qubit[] => Unit is Adj)) : Unit {
        // Prepare a reference register entangled with the target register.
        use (reference, target) = (Qubit[nQubits], Qubit[nQubits]) {
            PrepareEntangledState(reference, target);
            actual(target);
            Adjoint expected(target);
            Adjoint PrepareEntangledState(reference, target);
            AssertAllZero(reference + target);
            ResetAll(target);
            ResetAll(reference);
        }
    }
}

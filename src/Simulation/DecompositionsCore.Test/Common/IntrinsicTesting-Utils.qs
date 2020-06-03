namespace IntrinsicTesting {
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Decompositions.Utilities as Utils;

    internal operation ApplyToFirstQubit (op : (Qubit => Unit), register : Qubit[]) : Unit {
        if (Length(register) == 0) {
            fail $"Must have at least one qubit to act on.";
        }

        op(register[0]);
    }

    internal operation ApplyToFirstQubitA (op : (Qubit => Unit is Adj), register : Qubit[]) : Unit {
        body (...) {
            if (Length(register) == 0) {
                fail $"Must have at least one qubit to act on.";
            }

            op(register[0]);
        }

        adjoint invert;
    }

    internal operation ApplyToFirstQubitC (op : (Qubit => Unit is Ctl), register : Qubit[]) : Unit {
        body (...) {
            if (Length(register) == 0) {
                fail $"Must have at least one qubit to act on.";
            }

            op(register[0]);
        }

        controlled distribute;
    }

    internal operation ApplyToFirstQubitCA (op : (Qubit => Unit is Adj + Ctl), register : Qubit[]) : Unit {
        body (...) {
            if (Length(register) == 0) {
                fail $"Must have at least one qubit to act on.";
            }

            op(register[0]);
        }

        adjoint invert;
        controlled distribute;
        controlled adjoint distribute;
    }

    internal operation ApplyToFirstTwoQubits (op : ((Qubit, Qubit) => Unit), register : Qubit[]) : Unit {
        if (Length(register) < 2) {
            fail $"Must have at least two qubits to act on.";
        }

        op(register[0], register[1]);
    }

    internal operation ApplyToFirstTwoQubitsA (op : ((Qubit, Qubit) => Unit is Adj), register : Qubit[]) : Unit {
        body (...) {
            if (Length(register) < 2) {
                fail $"Must have at least two qubits to act on.";
            }

            op(register[0], register[1]);
        }
        
        adjoint invert;
    }

    operation ApplyToFirstTwoQubitsC (op : ((Qubit, Qubit) => Unit is Ctl), register : Qubit[]) : Unit {
        body (...) {
            if (Length(register) < 2) {
                fail $"Must have at least two qubits to act on.";
            }

            op(register[0], register[1]);
        }
        
        controlled distribute;
    }

    internal operation ApplyToFirstTwoQubitsCA (op : ((Qubit, Qubit) => Unit is Adj + Ctl), register : Qubit[]) : Unit {
        body (...) {
            if (Length(register) < 2) {
                fail $"Must have at least two qubits to act on.";
            }

            op(register[0], register[1]);
        }
        
        adjoint invert;
        controlled distribute;
        controlled adjoint distribute;
    }

    internal operation ApplyToFirstThreeQubits (op : ((Qubit, Qubit, Qubit) => Unit), register : Qubit[]) : Unit {
        if (Length(register) < 3) {
            fail $"Must have at least three qubits to act on.";
        }

        op(register[0], register[1], register[2]);
    }

    internal operation ApplyToFirstThreeQubitsA (op : ((Qubit, Qubit, Qubit) => Unit is Adj), register : Qubit[]) : Unit {
        body (...) {
            if (Length(register) < 3) {
                fail $"Must have at least three qubits to act on.";
            }

            op(register[0], register[1], register[2]);
        }

        adjoint invert;
    }

    internal operation ApplyToFirstThreeQubitsC (op : ((Qubit, Qubit, Qubit) => Unit is Ctl), register : Qubit[]) : Unit {
        body (...) {
            if (Length(register) < 3) {
                fail $"Must have at least three qubits to act on.";
            }

            op(register[0], register[1], register[2]);
        }

        controlled distribute;
    }

    internal operation ApplyToFirstThreeQubitsCA (op : ((Qubit, Qubit, Qubit) => Unit is Adj + Ctl), register : Qubit[]) : Unit {
        body (...) {
            if (Length(register) < 3) {
                fail $"Must have at least three qubits to act on.";
            }

            op(register[0], register[1], register[2]);
        }

        adjoint invert;
        controlled distribute;
        controlled adjoint distribute;
    }

    internal operation AssertOperationsEqualReferencedQ1( actual : ((Qubit) => Unit), expected : ((Qubit) => Unit is Adj) ) : Unit {
        AssertOperationsEqualReferenced(2, ApplyToFirstQubit(actual,_), ApplyToFirstQubitA(expected,_));
    }

    internal operation AssertOperationsEqualReferencedQ2( actual : ((Qubit,Qubit) => Unit), expected : ((Qubit,Qubit) => Unit is Adj) ) : Unit {
        AssertOperationsEqualReferenced(2, ApplyToFirstTwoQubits(actual,_), ApplyToFirstTwoQubitsA(expected,_));
    }

    internal operation AssertOperationsEqualReferencedQ3( actual : ((Qubit,Qubit,Qubit) => Unit), expected : ((Qubit,Qubit,Qubit) => Unit is Adj) ) : Unit {
        AssertOperationsEqualReferenced(3, ApplyToFirstThreeQubits(actual,_), ApplyToFirstThreeQubitsA(expected,_));
    }

    internal operation ApplySinglyControlledCA<'T>(op : ('T => Unit is Adj + Ctl), (control : Qubit, arg : 'T)) : Unit is Adj + Ctl {
        Controlled op([control], arg);
    }

    internal operation ApplySinglyControlledCAQ2(op : ((Qubit,Qubit) => Unit is Adj + Ctl), (control : Qubit, qubit1 : Qubit, qubit2 : Qubit)) : Unit is Adj + Ctl {
        Controlled op([control], (qubit1, qubit2));
    }

    internal function SinglyControlled<'T>(op : ('T => Unit is Adj + Ctl)) : ((Qubit,'T) => Unit is Adj + Ctl) {
        return ApplySinglyControlledCA(op, _);
    }

    internal function SinglyControlledQ2(op : ((Qubit,Qubit) => Unit is Adj + Ctl)) : ((Qubit,Qubit,Qubit) => Unit is Adj + Ctl) {
        return ApplySinglyControlledCAQ2(op, _);
    }

    internal function ArrayAsTupleO<'T>(arr : 'T[]) : 'T {
        return (arr[0]);
    }

    internal function ArrayAsTupleAO<'T>(arr : 'T[]) : ('T[],'T) {
        return (arr[1 .. Length(arr) - 1], arr[0]);
    }

    internal function ArrayAsTupleOO<'T>(arr : 'T[]) : ('T,'T) {
        return (arr[0], arr[1]);
    }

    internal function ArrayAsTupleAIOO<'T>(arr : 'T[]) : ('T[],('T,'T)) {
        return (arr[2 .. Length(arr) - 1], (arr[0], arr[1]));
    }

    internal function ArrayAsTupleOOO<'T>(arr : 'T[]) : ('T,'T,'T) {
        return (arr[0], arr[1], arr[2]);
    }

    internal function ArrayAsTupleAIOOO<'T>(arr : 'T[]) : ('T[],('T,'T,'T)) {
        return (arr[3 .. Length(arr) - 1], (arr[0], arr[1],arr[2]));
    }

    internal function ArrayAsTupleAA<'T>(secondArraySize : Int,  arr : 'T[]) : ('T[],'T[]) {
        return (arr[secondArraySize .. Length(arr) - 1], (arr[0 .. secondArraySize - 1]));
    }

    internal function ArrayAsTupleOOIO<'T>( arr : 'T[]) : (('T,'T),'T) {
        return ((arr[0], arr[1]), arr[2]);
    }

    internal function ArrayAsTupleOIOO<'T>(arr : 'T[]) : ('T,('T,'T)) {
        return (arr[0],(arr[1], arr[2]));
    }

    internal operation ApplyComposedCA<'U,'V>(op : ('U => Unit is Adj + Ctl), fn : ('V -> 'U), arg : 'V) : Unit is Ctl + Adj {
        op(fn(arg));
    }

    internal operation ApplyComposedA<'U,'V>(op : ('U => Unit is Adj), fn : ('V -> 'U), arg : 'V) : Unit is Adj {
        op(fn(arg));
    }

    internal operation ApplyComposedC<'U,'V>(op : ('U => Unit is Ctl), fn : ('V -> 'U), arg : 'V) : Unit is Ctl {
        op(fn(arg));
    }

    internal operation ApplyComposed<'U,'V>(op : ('U => Unit), fn : ('V -> 'U), arg : 'V) : Unit {
        op(fn(arg));
    }

    internal operation IterateThroughCartesianProduct(bounds : Int[], op : (Int[] => Unit)) : Unit {
        mutable arr = new Int[Length(bounds)];
        mutable finished = false;

        repeat {
            if (not finished) {
                op(arr);
            }
        }
        until (finished)
        fixup {
            //computes the next element in the Cartesian product
            set arr w/= 0 <- arr[0] + 1;

            for (i in 0 .. Length(arr) - 2) {
                if (arr[i] == bounds[i]) {
                    set arr w/= i + 1 <- arr[i + 1] + 1;
                    set arr w/= i <- 0;
                }
            }

            if (arr[Length(arr) - 1] == bounds[Length(arr) - 1]) {
                set finished = true;
            }
        }
    }

    internal operation IterateThroughCartesianPower (power : Int, bound : Int, op : (Int[] => Unit)) : Unit {
        mutable arr = new Int[power];

        for (i in 0 .. power - 1) {
            set arr w/= i <- bound;
        }

        IterateThroughCartesianProduct(arr, op);
    }
    
    internal operation IterateThroughCartesianPowerP (power : Int, values : Pauli[], op : (Pauli[] => Unit)) : Unit {
        let opInt = ApplyComposed(op, Utils.ArrayFromIndiciesP(values,_),_);
        IterateThroughCartesianPower(power, Length(values), opInt);
    }
}
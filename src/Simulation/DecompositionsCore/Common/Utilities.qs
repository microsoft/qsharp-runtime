namespace Microsoft.Quantum.Targeting.Decompositions.Utilities {

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

    internal function ArrayFromIndiciesP(values : Pauli[], indicies : Int[]) : Pauli[] {
        mutable arr = new Pauli[Length(indicies)];
        for (i in 0 .. Length(indicies) - 1) {
            set arr w/= i <- values[indicies[i]];
        }
        return arr;
    }

    internal function ArrayFromIndiciesQ(values : Qubit[], indicies : Int[]) : Qubit[] {
        mutable arr = new Qubit[Length(indicies)];
        for (i in 0 .. Length(indicies) - 1) {
            set arr w/= i <- values[indicies[i]];
        }
        return arr;
    }

    internal function IndicesOfNonIdentity(paulies : Pauli[]) : Int[] {
        mutable nonIdPauliCount = 0;

        for (i in 0 .. Length(paulies) - 1) {
            if (paulies[i] != PauliI) { set nonIdPauliCount += 1; }
        }
        
        mutable indices = new Int[nonIdPauliCount];
        mutable index = 0;
        
        for (i in 0 .. Length(paulies) - 1) {
            if (paulies[i] != PauliI) {
                set indices w/= index <- i;
                set index = index + 1;
            }
        }
        
        return indices;
    }
 
    internal function ReducedDyadicFraction(numerator : Int, denominatorPowerOfTwo : Int) : (Int,Int) {
        if (numerator == 0) { return (0,0); }
        mutable num = numerator;
        mutable denPow = denominatorPowerOfTwo;
        while( num % 2 == 0 ) {
            set num /= 2;
            set denPow += 1;
        }
        return (num,denPow);
    }

    internal function ReducedDyadicFractionPeriodic(numerator : Int, denominatorPowerOfTwo : Int) : (Int,Int) {
        let (k,n) = ReducedDyadicFraction(numerator,denominatorPowerOfTwo); // k is odd, or (k,n) are both 0
        let period = 2*2^n; // \pi k / 2^n is 2\pi periodic, therefore k is 2 * 2^n periodic
        let kMod = k % period; // if k was negative, we get kMod in a range [-period + 1, 0]
        let kModPositive = kMod >= 0 ? kMod | kMod + period; // kModPositive is in the range [0, period - 1]
        return (kModPositive, n);
    }

    /// # Summary 
    /// Returns π×numerator/2^(denominatorPowerOfTwo) as Double
    internal function DyadicFractionAsDouble(numerator : Int, denominatorPowerOfTwo : Int) : Double {
        let numeratorD = Microsoft.Quantum.Math.PI() * Microsoft.Quantum.Convert.IntAsDouble(numerator);
        return numeratorD * Microsoft.Quantum.Math.PowD(2.0, Microsoft.Quantum.Convert.IntAsDouble(-denominatorPowerOfTwo));
    }

    internal function RemovePauliI(paulis : Pauli[], qubits : Qubit[]) : (Pauli[], Qubit[]) {
        let indices = IndicesOfNonIdentity(paulis);
        let newPaulis = ArrayFromIndiciesP(paulis, indices);
        let newQubits = ArrayFromIndiciesQ(qubits, indices);
        return (newPaulis, newQubits);
    }
}
namespace Microsoft.Quantum.Decompositions.Utilities {

    function ArrayFromIndiciesP(values : Pauli[], indicies : Int[]) : Pauli[] {
        mutable arr = new Pauli[Length(indicies)];
        for (i in 0 .. Length(indicies) - 1) {
            set arr w/= i <- values[indicies[i]];
        }
        return arr;
    }

    function ArrayFromIndiciesQ(values : Qubit[], indicies : Int[]) : Qubit[] {
        mutable arr = new Qubit[Length(indicies)];
        for (i in 0 .. Length(indicies) - 1) {
            set arr w/= i <- values[indicies[i]];
        }
        return arr;
    }

    function IndicesOfNonIdentity(paulies : Pauli[]) : Int[] {
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

    function ReducedDyadicFraction(numerator : Int, denominatorPowerOfTwo : Int) : (Int,Int) {
        if (numerator == 0) { return (0,0); }
        mutable num = numerator;
        mutable denPow = denominatorPowerOfTwo;
        while( num % 2 == 0 ) {
            set num /= 2;
            set denPow += 1;
        }
        return (num,denPow);
    }

    function ReducedDyadicFractionPeriodic(numerator : Int, denominatorPowerOfTwo : Int) : (Int,Int) {
        let (k,n) = ReducedDyadicFraction(numerator,denominatorPowerOfTwo); // k is odd, or (k,n) are both 0
        let period = 2*2^n; // \pi k / 2^n is 2\pi periodic, therefore k is 2 * 2^n periodic
        let kMod = k % period; // if k was negative, we get kMod in a range [-period + 1, 0]
        let kModPositive = kMod >= 0 ? kMod | kMod + period; // kModPositive is in the range [0, period - 1]
        return (kModPositive, n);
    }

    /// # Summary 
    /// Returns π×numerator/2^(denominatorPowerOfTwo) as Double
    function DyadicFractionAsDouble(numerator : Int, denominatorPowerOfTwo : Int) : Double {
        let numeratorD = Microsoft.Quantum.Math.PI() * Microsoft.Quantum.Convert.IntAsDouble(numerator);
        return numeratorD * Microsoft.Quantum.Math.PowD(2.0, Microsoft.Quantum.Convert.IntAsDouble(-denominatorPowerOfTwo));
    }

    function RemovePauliI(paulis : Pauli[], qubits : Qubit[]) : (Pauli[], Qubit[]) {
        let indices = IndicesOfNonIdentity(paulis);
        let newPaulis = ArrayFromIndiciesP(paulis, indices);
        let newQubits = ArrayFromIndiciesQ(qubits, indices);
        return (newPaulis, newQubits);
    }
}
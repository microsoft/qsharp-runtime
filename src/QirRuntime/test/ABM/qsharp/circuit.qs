namespace StreamlinedBenchmarks {
    open Microsoft.Quantum.Intrinsic;

   operation Reset (target : Qubit) : Unit {
        if (M(target) == One) {
            X(target);
        }
    }

    operation ResetAll (qubits : Qubit[]) : Unit {
        for (qubit in qubits) {
            Reset(qubit);
        }
    }    

    operation applyRotations(angles:Double[],reg:Qubit[],nQ: Int): Unit{
        mutable n = Length(angles)/2;
        if (n > nQ) {set n=nQ;}
        for (j in 0..(n-1))
        {
            Rz(angles[2*j],reg[j]);
            Rx(angles[2*j+1],reg[j]);
        }
    }

    operation applyLadder(angles:Double[],reg:Qubit[],nQ: Int): Unit{
        mutable n = Length(angles)/2;
        if (n > nQ) {set n=nQ;}
        
        (Controlled Rz)([reg[n-1]], (angles[0],reg[0])) ;
        (Controlled Rx)([reg[n-1]], (angles[1],reg[0])) ;
        for (j in 0..(n-2))
        {
            (Controlled Rz)([reg[j]], (angles[2*j+2],reg[j+1])) ;
            (Controlled Rx)([reg[j]], (angles[2*j+3],reg[j+1])) ;
        }
    }

    operation OnSquareCircuit(angles:Double[], nQ: Int, reps: Int) : Unit {
        using (reg = Qubit[nQ])
        {
            for (j in 1..(reps))
            {
                for (k in 0..(nQ-1))
                {
                    applyRotations(angles[2*k*nQ..2*k*nQ+2*nQ-1],reg,nQ);
                    applyLadder(angles[2*k*nQ..2*k*nQ+2*nQ-1],reg,nQ);
                }
            }
            ResetAll(reg);
        }
    }

    operation OnCircuit(angles:Double[], nQ: Int, reps: Int) : Unit {
        using (reg = Qubit[nQ])
        {
            for (j in 1..reps)
            {
                applyRotations(angles,reg,nQ);
                applyLadder(angles,reg,nQ);
            }
            ResetAll(reg);
        }
    }

    @EntryPoint()
    operation Benchmark(angles:Double[], nQ: Int, reps: Int, linear: Bool) : Unit {
        if (linear) { OnCircuit(angles, nQ, reps); }
        else { OnSquareCircuit(angles, nQ, reps); }
    }
}


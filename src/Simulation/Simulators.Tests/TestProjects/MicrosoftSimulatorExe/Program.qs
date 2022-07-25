namespace Quantum.MicrosoftSimulatorExe {

    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Measurement;

    operation ApplyToEachCA<'T> (singleElementOperation : ('T => Unit is Adj + Ctl), register : 'T[])
    : Unit is Adj + Ctl {
        for q in register {
            singleElementOperation(q);
        }
    }
    
    operation ForEach<'T, 'U> (action : ('T => 'U), array : 'T[]) : 'U[] {
        let length = Length(array);
        if length == 0 {
            return [];
        }
        let first = action(array[0]);
        mutable retval = [first, size = length];
        for idx in 1..length - 1 {
            set retval w/= idx <- action(array[idx]);
        }
        return retval;
    }

    @EntryPoint()
    operation HelloQ () : Unit {
        use qubits = Qubit[10]
        {
            ApplyToEachCA(H, qubits);
            let resuls = ForEach(MResetZ, qubits);
        }
    }
}

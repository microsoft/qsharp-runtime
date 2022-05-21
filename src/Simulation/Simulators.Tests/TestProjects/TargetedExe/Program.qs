namespace Microsoft.Quantum.Testing {

    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Measurement;
    
    @EntryPoint()
    operation CallGenerics() : Int {

        use qs = Qubit[2];
        for q in qs {
            H(q);        
        }

        return 12345;
    }
}

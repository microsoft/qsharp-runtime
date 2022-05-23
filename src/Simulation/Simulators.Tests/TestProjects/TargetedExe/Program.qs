namespace Microsoft.Quantum.Testing {

    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Measurement;
    open Microsoft.Quantum.Canon;

    @EntryPoint()
    operation Main() : Int {
    
        use qs = Qubit[2];
        Ignore(Measure([PauliX, PauliX], qs));
        ResetAll(qs);

        return 12345;
    }
}

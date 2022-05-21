namespace Microsoft.Quantum.Testing.Honeywell.Monomorphization {

    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Measurement;
    open Microsoft.Quantum.Canon;
    
    @EntryPoint()
    operation CallGenerics() : Int {

        use qs = Qubit[2] {
            Ignore(Measure([PauliX, PauliX], qs));
            ResetAll(qs);
            return 12345;
        }
    }
}

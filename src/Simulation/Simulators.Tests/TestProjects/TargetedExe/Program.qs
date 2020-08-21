namespace Microsoft.Quantum.Testing.Honeywell.Monomorphization {

    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Measurement;
    open Microsoft.Quantum.Canon;
    
    @EntryPoint()
    operation CallGenerics() : String {

        let arr = Default<Qubit[]>();
        using (qs = Qubit[2])  {
            Ignore(Measure([PauliX, PauliX], qs));
            return "TargetedExe";
        }
    }
}

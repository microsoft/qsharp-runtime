namespace Tets.Samples {

    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Measurement;
    open Microsoft.Quantum.Intrinsic;

    @EntryPoint()
    operation RandomBit() : Result {
        
        using (q = Qubit()) {
            H(q);
            return MResetZ(q);
        }
    }
}

namespace QsharpExe {

    open Microsoft.Quantum.Intrinsic;

    @EntryPoint()
    operation Main () : Result {
        using (q = Qubit()) {
            H(q);
            let res = M(q);
            if (res == One) {
                X(q);
            }
            return res;
        }
    }
}

namespace Sample {

    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Diagnostics;

    operation HelloQ() : Result {
        using (q = Qubit()) {
            Message("Hello from quantum");
            H(q);
            return M(q);
        }
    }
}


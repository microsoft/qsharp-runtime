namespace Microsoft.Quantum.Simulation.Testing.Honeywell.IfStatements {

    open Microsoft.Quantum.Intrinsic;
    
    operation SimpleIf () : Unit {
        using (q = Qubit()) {
            H(q);
            if (M(q) == One) {
                X(q);                
            }
        }
    }
}

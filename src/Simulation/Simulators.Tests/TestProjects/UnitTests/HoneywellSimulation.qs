namespace Microsoft.Quantum.Simulation.Testing.Honeywell {

    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Simulation.Testing.Honeywell.IfStatements;


    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    operation SimpleIfTest () : Unit {
        SimpleIf();
    }
}

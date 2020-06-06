namespace Quantum.UnitTests {

    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Intrinsic;

    @Test("QuantumSimulator")
    operation LoadBothCollisionsViaTestNames () : Unit {
        
        Library1.Hello();
        Library2.Hello();
    }
}

namespace Quantum.UnitTests {

    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Intrinsic;


    @Test("QuantumSimulator")
    operation LoadBothViaTestNames () : Unit {
        
        Fact(1, Library1.LibraryId());
        Fact(2, Library2.LibraryId());
    }

    @Test("QuantumSimulator")
    operation LoadOneViaTestName () : Unit {

        Fact("Library1", DllName());
        Fact("Library2", Library2.DllName());
    }
}

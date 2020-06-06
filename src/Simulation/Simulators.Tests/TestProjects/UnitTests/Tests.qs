namespace Microsoft.Quantum.Testing.LoadViaTestName {

    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Intrinsic;

    internal function FactI(expected : Int, got : Int) : Unit {
        if (expected != got) {
            fail $"Expected: {expected}, got: {got}";
        }
    }

    internal function FactS(expected : String, got : String) : Unit {
        if (expected != got) {
            fail $"Expected: {expected}, got: {got}";
        }
    }

    @Test("QuantumSimulator")
    operation LoadBothViaTestNames () : Unit {
        
        FactI(1, Library1.LibraryId());
        FactI(2, Library2.LibraryId());
    }

    @Test("QuantumSimulator")
    operation LoadOneViaTestName () : Unit {

        FactS("Library1", Microsoft.Quantum.Library.DllName());
        FactS("Library2", Library2.DllName());
    }
}

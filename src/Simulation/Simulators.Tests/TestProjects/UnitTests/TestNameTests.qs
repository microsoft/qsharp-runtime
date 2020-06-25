﻿namespace Microsoft.Quantum.Testing.LoadViaTestName {

    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Testing;

    @Test("QuantumSimulator")
    operation BothCallables () : Unit {
        
        FactI(1, Library1.LibraryId());
        FactI(2, Library2.LibraryId());
    }

    @Test("QuantumSimulator")
    operation OneCallable () : Unit {

        FactS("Library1", Microsoft.Quantum.Library.DllName());
        FactS("Library2", Library2.DllName());
    }

    @Test("QuantumSimulator")
    operation BothTypes () : Unit {
        
        let i1 = Library1.MyInt(1);
        let i2 = Library2.MyInt(2);
        FactMyInt1(1, i1);
        FactMyInt2(2, i2);
    }

    @Test("QuantumSimulator")
    operation OneType () : Unit {
        
        let s1 = Microsoft.Quantum.Library.MyString("Library1");
        let s2 = Library2.MyString("Library2");
        FactMyString1("Library1", s1);
        FactMyString2("Library2", s2);
    }

    @Test("QuantumSimulator")
    operation ConflictingWithSource () : Unit {

        let h1 = Library1.Hello(Library1.Token());
        let h2 = Microsoft.Quantum.Library.Hello(Microsoft.Quantum.Library.Token());
        FactS("Hello from Library1!", h1);
        return h2;
    }

}

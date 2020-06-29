namespace Microsoft.Quantum.Testing {
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

    internal function FactMyInt1(expected : Int, got : Library1.MyInt) : Unit {
        if (expected != got::Value1) {
            fail $"Expected: {expected}, got: {got::Value1}";
        }
    }

    internal function FactMyInt2(expected : Int, got : Library2.MyInt) : Unit {
        if (expected != got::Value2) {
            fail $"Expected: {expected}, got: {got::Value2}";
        }
    }

    internal function FactMyString1(expected : String, got : Microsoft.Quantum.Library.MyString) : Unit {
        if (expected != got::Text) {
            fail $"Expected: {expected}, got: {got::Text}";
        }
    }

    internal function FactMyString2(expected : String, got : Library2.MyString) : Unit {
        if (expected != got::Text) {
            fail $"Expected: {expected}, got: {got::Text}";
        }
    }
}

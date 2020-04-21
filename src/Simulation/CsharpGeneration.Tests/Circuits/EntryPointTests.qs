// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

//
// No Options
//

namespace Microsoft.Quantum.CsharpGeneration.Testing.EntryPoint {
    @EntryPoint()
    operation ReturnUnit() : Unit { }
}

// ---

namespace Microsoft.Quantum.CsharpGeneration.Testing.EntryPoint {
    @EntryPoint()
    operation ReturnInt() : Int {
        return 42;
    }
}

// ---

namespace Microsoft.Quantum.CsharpGeneration.Testing.EntryPoint {
    @EntryPoint()
    operation ReturnString() : String {
        return "Hello, World!";
    }
}

// ---

//
// Single Option
//

namespace Microsoft.Quantum.CsharpGeneration.Testing.EntryPoint {
    @EntryPoint()
    operation AcceptInt(n : Int) : Int {
        return n;
    }
}

// ---

namespace Microsoft.Quantum.CsharpGeneration.Testing.EntryPoint {
    @EntryPoint()
    operation AcceptBigInt(n : BigInt) : BigInt {
        return n;
    }
}

// ---

namespace Microsoft.Quantum.CsharpGeneration.Testing.EntryPoint {
    @EntryPoint()
    operation AcceptDouble(n : Double) : Double {
        return n;
    }
}

// ---

namespace Microsoft.Quantum.CsharpGeneration.Testing.EntryPoint {
    @EntryPoint()
    operation AcceptBool(b : Bool) : Bool {
        return b;
    }
}

// ---

namespace Microsoft.Quantum.CsharpGeneration.Testing.EntryPoint {
    @EntryPoint()
    operation AcceptPauli(p : Pauli) : Pauli {
        return p;
    }
}

// ---

namespace Microsoft.Quantum.CsharpGeneration.Testing.EntryPoint {
    @EntryPoint()
    operation AcceptResult(r : Result) : Result {
        return r;
    }
}

// ---

namespace Microsoft.Quantum.CsharpGeneration.Testing.EntryPoint {
    @EntryPoint()
    operation AcceptRange(r : Range) : Range {
        return r;
    }
}

// ---

namespace Microsoft.Quantum.CsharpGeneration.Testing.EntryPoint {
    @EntryPoint()
    operation AcceptString(s : String) : String {
        return s;
    }
}

// ---

namespace Microsoft.Quantum.CsharpGeneration.Testing.EntryPoint {
    @EntryPoint()
    operation AcceptStringArray(xs : String[]) : String[] {
        return xs;
    }
}

// ---

namespace Microsoft.Quantum.CsharpGeneration.Testing.EntryPoint {
    @EntryPoint()
    operation AcceptUnit(u : Unit) : Unit {
        return u;
    }
}

// ---

//
// Help
//

namespace Microsoft.Quantum.CsharpGeneration.Testing.EntryPoint {
    /// # Summary
    /// This test checks that the entry point documentation appears correctly in the command line help message.
    ///
    /// # Input
    /// ## n
    /// A number.
    /// 
    /// ## pauli
    /// The name of a Pauli matrix.
    ///
    /// ## myCoolBool
    /// A neat bit.
    @EntryPoint()
    operation Help(n : Int, pauli : Pauli, myCoolBool : Bool) : Unit { }
}

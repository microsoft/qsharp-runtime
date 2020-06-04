// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

//
// No Options
//

namespace Microsoft.Quantum.CsharpGeneration.EntryPointDriver.Tests {
    @EntryPoint()
    operation ReturnUnit() : Unit { }
}

// ---

namespace Microsoft.Quantum.CsharpGeneration.EntryPointDriver.Tests {
    @EntryPoint()
    operation ReturnInt() : Int {
        return 42;
    }
}

// ---

namespace Microsoft.Quantum.CsharpGeneration.EntryPointDriver.Tests {
    @EntryPoint()
    operation ReturnString() : String {
        return "Hello, World!";
    }
}

// ---

//
// Single Option
//

namespace Microsoft.Quantum.CsharpGeneration.EntryPointDriver.Tests {
    @EntryPoint()
    operation AcceptInt(n : Int) : Int {
        return n;
    }
}

// ---

namespace Microsoft.Quantum.CsharpGeneration.EntryPointDriver.Tests {
    @EntryPoint()
    operation AcceptBigInt(n : BigInt) : BigInt {
        return n;
    }
}

// ---

namespace Microsoft.Quantum.CsharpGeneration.EntryPointDriver.Tests {
    @EntryPoint()
    operation AcceptDouble(n : Double) : Double {
        return n;
    }
}

// ---

namespace Microsoft.Quantum.CsharpGeneration.EntryPointDriver.Tests {
    @EntryPoint()
    operation AcceptBool(b : Bool) : Bool {
        return b;
    }
}

// ---

namespace Microsoft.Quantum.CsharpGeneration.EntryPointDriver.Tests {
    @EntryPoint()
    operation AcceptPauli(p : Pauli) : Pauli {
        return p;
    }
}

// ---

namespace Microsoft.Quantum.CsharpGeneration.EntryPointDriver.Tests {
    @EntryPoint()
    operation AcceptResult(r : Result) : Result {
        return r;
    }
}

// ---

namespace Microsoft.Quantum.CsharpGeneration.EntryPointDriver.Tests {
    @EntryPoint()
    operation AcceptRange(r : Range) : Range {
        return r;
    }
}

// ---

namespace Microsoft.Quantum.CsharpGeneration.EntryPointDriver.Tests {
    @EntryPoint()
    operation AcceptString(s : String) : String {
        return s;
    }
}

// ---

namespace Microsoft.Quantum.CsharpGeneration.EntryPointDriver.Tests {
    @EntryPoint()
    operation AcceptUnit(u : Unit) : Unit {
        return u;
    }
}

// ---

namespace Microsoft.Quantum.CsharpGeneration.EntryPointDriver.Tests {
    @EntryPoint()
    operation AcceptStringArray(xs : String[]) : String[] {
        return xs;
    }
}

// ---

namespace Microsoft.Quantum.CsharpGeneration.EntryPointDriver.Tests {
    @EntryPoint()
    operation AcceptBigIntArray(bs : BigInt[]) : BigInt[] {
        return bs;
    }
}

// ---

namespace Microsoft.Quantum.CsharpGeneration.EntryPointDriver.Tests {
    @EntryPoint()
    operation AcceptPauliArray(ps : Pauli[]) : Pauli[] {
        return ps;
    }
}

// ---

namespace Microsoft.Quantum.CsharpGeneration.EntryPointDriver.Tests {
    @EntryPoint()
    operation AcceptRangeArray(rs : Range[]) : Range[] {
        return rs;
    }
}

// ---

namespace Microsoft.Quantum.CsharpGeneration.EntryPointDriver.Tests {
    @EntryPoint()
    operation AcceptResultArray(rs : Result[]) : Result[] {
        return rs;
    }
}

// ---

namespace Microsoft.Quantum.CsharpGeneration.EntryPointDriver.Tests {
    @EntryPoint()
    operation AcceptUnitArray(us : Unit[]) : Unit[] {
        return us;
    }
}

// ---

//
// Multiple Options
//

namespace Microsoft.Quantum.CsharpGeneration.EntryPointDriver.Tests {
    @EntryPoint()
    operation TwoOptions(n : Int, b : Bool) : String {
        return $"{n} {b}";
    }
}

// ---

namespace Microsoft.Quantum.CsharpGeneration.EntryPointDriver.Tests {
    @EntryPoint()
    operation ThreeOptions(n : Int, b : Bool, xs : String[]) : String {
        return $"{n} {b} {xs}";
    }
}

// ---

//
// Tuples
//

namespace Microsoft.Quantum.CsharpGeneration.EntryPointDriver.Tests {
    @EntryPoint()
    operation RedundantOneTuple((x : Int)) : String {
        return $"{x}";
    }
}

// ---

namespace Microsoft.Quantum.CsharpGeneration.EntryPointDriver.Tests {
    @EntryPoint()
    operation RedundantTwoTuple((x : Int, y : Int)) : String {
        return $"{x} {y}";
    }
}

// ---

namespace Microsoft.Quantum.CsharpGeneration.EntryPointDriver.Tests {
    @EntryPoint()
    operation OneTuple(x : Int, (y : Int)) : String {
        return $"{x} {y}";
    }
}

// ---

namespace Microsoft.Quantum.CsharpGeneration.EntryPointDriver.Tests {
    @EntryPoint()
    operation TwoTuple(x : Int, (y : Int, z : Int)) : String {
        return $"{x} {y} {z}";
    }
}

// ---

//
// Name Conversion
//

namespace Microsoft.Quantum.CsharpGeneration.EntryPointDriver.Tests {
    @EntryPoint()
    operation CamelCase(camelCaseName : String) : String {
        return camelCaseName;
    }
}

// ---

namespace Microsoft.Quantum.CsharpGeneration.EntryPointDriver.Tests {
    @EntryPoint()
    operation SingleLetter(x : String) : String {
        return x;
    }
}

// ---

//
// Shadowing
//

namespace Microsoft.Quantum.CsharpGeneration.EntryPointDriver.Tests {
    @EntryPoint()
    operation ShadowSimulator(simulator : String) : String {
        return simulator;
    }
}

// ---

namespace Microsoft.Quantum.CsharpGeneration.EntryPointDriver.Tests {
    @EntryPoint()
    operation ShadowS(s : String) : String {
        return s;
    }
}

// ---

namespace Microsoft.Quantum.CsharpGeneration.EntryPointDriver.Tests {
    @EntryPoint()
    operation ShadowVersion(version : String) : String {
        return version;
    }
}

// ---

namespace Microsoft.Quantum.CsharpGeneration.EntryPointDriver.Tests {
    @EntryPoint()
    operation ShadowTarget(target : String) : String {
        return target;
    }
}

// ---

namespace Microsoft.Quantum.CsharpGeneration.EntryPointDriver.Tests {
    @EntryPoint()
    operation ShadowShots(shots : Int) : Int {
        return shots;
    }
}

// ---

//
// Simulators
//

namespace Microsoft.Quantum.CsharpGeneration.EntryPointDriver.Tests {
    open Microsoft.Quantum.Intrinsic;

    @EntryPoint()
    operation XOrH(useH : Bool) : String {
        using (q = Qubit()) {
            if (useH) {
                H(q);
            } else {
                X(q);
            }

            if (M(q) == One) {
                X(q);
            }
        }
        return "Hello, World!";
    }
}

// ---

//
// Help
//

namespace Microsoft.Quantum.CsharpGeneration.EntryPointDriver.Tests {
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

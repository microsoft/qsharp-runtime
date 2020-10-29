// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

//
// No Options
//

namespace EntryPointTest {
    @EntryPoint()
    operation ReturnUnit() : Unit { }
}

// ---

namespace EntryPointTest {
    @EntryPoint()
    operation ReturnInt() : Int {
        return 42;
    }
}

// ---

namespace EntryPointTest {
    @EntryPoint()
    operation ReturnString() : String {
        return "Hello, World!";
    }
}

// ---

namespace EntryPointTest {
    @EntryPoint()
    operation EntryPointTest() : Unit { }
}

// ---

//
// Single Option
//

namespace EntryPointTest {
    @EntryPoint()
    operation AcceptInt(n : Int) : Int {
        return n;
    }
}

// ---

namespace EntryPointTest {
    @EntryPoint()
    operation AcceptBigInt(n : BigInt) : BigInt {
        return n;
    }
}

// ---

namespace EntryPointTest {
    @EntryPoint()
    operation AcceptDouble(n : Double) : Double {
        return n;
    }
}

// ---

namespace EntryPointTest {
    @EntryPoint()
    operation AcceptBool(b : Bool) : Bool {
        return b;
    }
}

// ---

namespace EntryPointTest {
    @EntryPoint()
    operation AcceptPauli(p : Pauli) : Pauli {
        return p;
    }
}

// ---

namespace EntryPointTest {
    @EntryPoint()
    operation AcceptResult(r : Result) : Result {
        return r;
    }
}

// ---

namespace EntryPointTest {
    @EntryPoint()
    operation AcceptRange(r : Range) : Range {
        return r;
    }
}

// ---

namespace EntryPointTest {
    @EntryPoint()
    operation AcceptString(s : String) : String {
        return s;
    }
}

// ---

namespace EntryPointTest {
    @EntryPoint()
    operation AcceptUnit(u : Unit) : Unit {
        return u;
    }
}

// ---

namespace EntryPointTest {
    @EntryPoint()
    operation AcceptStringArray(xs : String[]) : String[] {
        return xs;
    }
}

// ---

namespace EntryPointTest {
    @EntryPoint()
    operation AcceptBigIntArray(bs : BigInt[]) : BigInt[] {
        return bs;
    }
}

// ---

namespace EntryPointTest {
    @EntryPoint()
    operation AcceptPauliArray(ps : Pauli[]) : Pauli[] {
        return ps;
    }
}

// ---

namespace EntryPointTest {
    @EntryPoint()
    operation AcceptRangeArray(rs : Range[]) : Range[] {
        return rs;
    }
}

// ---

namespace EntryPointTest {
    @EntryPoint()
    operation AcceptResultArray(rs : Result[]) : Result[] {
        return rs;
    }
}

// ---

namespace EntryPointTest {
    @EntryPoint()
    operation AcceptUnitArray(us : Unit[]) : Unit[] {
        return us;
    }
}

// ---

//
// Multiple Options
//

namespace EntryPointTest {
    @EntryPoint()
    operation TwoOptions(n : Int, b : Bool) : String {
        return $"{n} {b}";
    }
}

// ---

namespace EntryPointTest {
    @EntryPoint()
    operation ThreeOptions(n : Int, b : Bool, xs : String[]) : String {
        return $"{n} {b} {xs}";
    }
}

// ---

//
// Tuples
//

namespace EntryPointTest {
    @EntryPoint()
    operation RedundantOneTuple((x : Int)) : String {
        return $"{x}";
    }
}

// ---

namespace EntryPointTest {
    @EntryPoint()
    operation RedundantTwoTuple((x : Int, y : Int)) : String {
        return $"{x} {y}";
    }
}

// ---

namespace EntryPointTest {
    @EntryPoint()
    operation OneTuple(x : Int, (y : Int)) : String {
        return $"{x} {y}";
    }
}

// ---

namespace EntryPointTest {
    @EntryPoint()
    operation TwoTuple(x : Int, (y : Int, z : Int)) : String {
        return $"{x} {y} {z}";
    }
}

// ---

//
// Name Conversion
//

namespace EntryPointTest {
    @EntryPoint()
    operation CamelCase(camelCaseName : String) : String {
        return camelCaseName;
    }
}

// ---

namespace EntryPointTest {
    @EntryPoint()
    operation SingleLetter(x : String) : String {
        return x;
    }
}

// ---

//
// Shadowing
//

namespace EntryPointTest {
    @EntryPoint()
    operation ShadowSimulator(simulator : String) : String {
        return simulator;
    }
}

// ---

namespace EntryPointTest {
    @EntryPoint()
    operation ShadowS(s : String) : String {
        return s;
    }
}

// ---

namespace EntryPointTest {
    @EntryPoint()
    operation ShadowVersion(version : String) : String {
        return version;
    }
}

// ---

namespace EntryPointTest {
    @EntryPoint()
    operation ShadowTarget(target : String) : String {
        return target;
    }
}

// ---

namespace EntryPointTest {
    @EntryPoint()
    operation ShadowShots(shots : Int) : Int {
        return shots;
    }
}

// ---

//
// Simulators
//

namespace EntryPointTest {
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

namespace EntryPointTest {
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

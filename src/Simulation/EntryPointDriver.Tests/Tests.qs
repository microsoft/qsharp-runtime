// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

// Each test case is separated by "// ---". The text immediately after "// ---" until the end of the line is the name of
// the test case, which usually corresponds to a test name in Tests.fs.

//
// No Options
//

// --- Returns Unit

namespace EntryPointTest {
    @EntryPoint()
    operation ReturnUnit() : Unit { }
}

// --- Returns Int

namespace EntryPointTest {
    @EntryPoint()
    operation ReturnInt() : Int {
        return 42;
    }
}

// --- Returns String

namespace EntryPointTest {
    @EntryPoint()
    operation ReturnString() : String {
        return "Hello, World!";
    }
}

// --- Namespace and callable use same name

namespace EntryPointTest {
    @EntryPoint()
    operation EntryPointTest() : Unit { }
}

//
// Single Option
//

// --- Accepts Int

namespace EntryPointTest {
    @EntryPoint()
    operation AcceptInt(n : Int) : Int {
        return n;
    }
}

// --- Accepts BigInt

namespace EntryPointTest {
    @EntryPoint()
    operation AcceptBigInt(n : BigInt) : BigInt {
        return n;
    }
}

// --- Accepts Double

namespace EntryPointTest {
    @EntryPoint()
    operation AcceptDouble(n : Double) : Double {
        return n;
    }
}

// --- Accepts Bool

namespace EntryPointTest {
    @EntryPoint()
    operation AcceptBool(b : Bool) : Bool {
        return b;
    }
}

// --- Accepts Pauli

namespace EntryPointTest {
    @EntryPoint()
    operation AcceptPauli(p : Pauli) : Pauli {
        return p;
    }
}

// --- Accepts Result

namespace EntryPointTest {
    @EntryPoint()
    operation AcceptResult(r : Result) : Result {
        return r;
    }
}

// --- Accepts Range

namespace EntryPointTest {
    @EntryPoint()
    operation AcceptRange(r : Range) : Range {
        return r;
    }
}

// --- Accepts String

namespace EntryPointTest {
    @EntryPoint()
    operation AcceptString(s : String) : String {
        return s;
    }
}

// --- Accepts Unit

namespace EntryPointTest {
    @EntryPoint()
    operation AcceptUnit(u : Unit) : Unit {
        return u;
    }
}

// --- Accepts String array

namespace EntryPointTest {
    @EntryPoint()
    operation AcceptStringArray(xs : String[]) : String[] {
        return xs;
    }
}

// --- Accepts BigInt array

namespace EntryPointTest {
    @EntryPoint()
    operation AcceptBigIntArray(bs : BigInt[]) : BigInt[] {
        return bs;
    }
}

// --- Accepts Pauli array

namespace EntryPointTest {
    @EntryPoint()
    operation AcceptPauliArray(ps : Pauli[]) : Pauli[] {
        return ps;
    }
}

// --- Accepts Range array

namespace EntryPointTest {
    @EntryPoint()
    operation AcceptRangeArray(rs : Range[]) : Range[] {
        return rs;
    }
}

// --- Accepts Result array

namespace EntryPointTest {
    @EntryPoint()
    operation AcceptResultArray(rs : Result[]) : Result[] {
        return rs;
    }
}

// --- Accepts Unit array

namespace EntryPointTest {
    @EntryPoint()
    operation AcceptUnitArray(us : Unit[]) : Unit[] {
        return us;
    }
}

//
// Multiple Options
//

// --- Accepts two options

namespace EntryPointTest {
    @EntryPoint()
    operation TwoOptions(n : Int, b : Bool) : String {
        return $"{n} {b}";
    }
}

// --- Accepts three options

namespace EntryPointTest {
    @EntryPoint()
    operation ThreeOptions(n : Int, b : Bool, xs : String[]) : String {
        return $"{n} {b} {xs}";
    }
}

//
// Tuples
//

// --- Accepts redundant one-tuple

namespace EntryPointTest {
    @EntryPoint()
    operation RedundantOneTuple((x : Int)) : String {
        return $"{x}";
    }
}

// --- Accepts redundant two-tuple

namespace EntryPointTest {
    @EntryPoint()
    operation RedundantTwoTuple((x : Int, y : Int)) : String {
        return $"{x} {y}";
    }
}

// --- Accepts one-tuple

namespace EntryPointTest {
    @EntryPoint()
    operation OneTuple(x : Int, (y : Int)) : String {
        return $"{x} {y}";
    }
}

// --- Accepts two-tuple

namespace EntryPointTest {
    @EntryPoint()
    operation TwoTuple(x : Int, (y : Int, z : Int)) : String {
        return $"{x} {y} {z}";
    }
}

//
// Name Conversion
//

// --- Uses kebab-case

namespace EntryPointTest {
    @EntryPoint()
    operation CamelCase(camelCaseName : String) : String {
        return camelCaseName;
    }
}

// --- Uses single-dash short names

namespace EntryPointTest {
    @EntryPoint()
    operation SingleLetter(x : String) : String {
        return x;
    }
}

//
// Shadowing
//

// --- Shadows --simulator

namespace EntryPointTest {
    @EntryPoint()
    operation ShadowSimulator(simulator : String) : String {
        return simulator;
    }
}

// --- Shadows -s

namespace EntryPointTest {
    @EntryPoint()
    operation ShadowS(s : String) : String {
        return s;
    }
}

// --- Shadows --version

namespace EntryPointTest {
    @EntryPoint()
    operation ShadowVersion(version : String) : String {
        return version;
    }
}

// --- Shadows --target

namespace EntryPointTest {
    @EntryPoint()
    operation ShadowTarget(target : String) : String {
        return target;
    }
}

// --- Shadows --shots

namespace EntryPointTest {
    @EntryPoint()
    operation ShadowShots(shots : Int) : Int {
        return shots;
    }
}

//
// Simulators
//

// --- X or H

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

//
// Help
//

// --- Help

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

//
// Multiple Entry Points
//

// --- Multiple entry points

namespace EntryPointTest {
    @EntryPoint()
    operation MultipleEntryPoints1() : String {
        return "Hello from Entry Point 1!";
    }

    @EntryPoint()
    operation MultipleEntryPoints2() : String {
        return "Hello from Entry Point 2!";
    }
}

// --- Multiple entry points with different parameters

namespace EntryPointTest {
    @EntryPoint()
    operation MultipleEntryPoints1(n : Double) : Double {
        return n;
    }

    @EntryPoint()
    operation MultipleEntryPoints2(s : String) : String {
        return s;
    }
}

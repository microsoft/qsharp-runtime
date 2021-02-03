// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Tests {

    // The EqualityFact★ functions are not yet defined, so we provide
    // definitions as internal functions for use in these tests.

    internal function FormattedFailure<'T>(actual : 'T, expected : 'T, message : String) : Unit {
        fail $"{message}\n\tExpected:\t{expected}\n\tActual:\t{actual}";
    }

    internal function EqualityFactI(actual : Int, expected : Int, message : String) : Unit {
        if (actual != expected) {
            FormattedFailure(actual, expected, message);
        }
    }

    internal function EqualityFactL(actual : BigInt, expected : BigInt, message : String) : Unit {
        if (actual != expected) {
            FormattedFailure(actual, expected, message);
        }
    }

    internal function EqualityFactS(actual : String, expected : String, message : String) : Unit {
        if (actual != expected) {
            FormattedFailure(actual, expected, message);
        }
    }

    internal function EqualityFactD(actual : Double, expected : Double, message : String) : Unit {
        if (actual != expected) {
            FormattedFailure(actual, expected, message);
        }
    }

    internal function EqualityWithinToleranceFact(actual : Double, expected : Double, tolerance : Double, message : String) : Unit {
        let delta = actual - expected;
        if (delta > tolerance or delta < -tolerance) {
            FormattedFailure(actual, expected, message);
        }
    }

}

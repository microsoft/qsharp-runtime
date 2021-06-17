// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

// # Design notes
//
// In testing the open systems simulator, we can't use the same approach used
// in testing other simulators. In particular, AssertMeasurement and
// AssertMeasurementProbability are no-ops on experimental simulators. Thus,
// we need to be a bit more indirect.
//
// Moreover, not all decompositions are supported yet
// (see documentation/experimental-simulators.md), such that we need to avoid
// unsupported cases.
//
// In this file, we list a bunch of operations that are unlikely to work
// correctly in the presence of decomposition bugs. This is not a guarantee,
// as we may have in the case of testing Choi–Jamilkowski states with
// assertions, but it should help build confidence in experimental simulator
// decompositions.
//
// In the future, consolidating these decompositions with those used in other
// targeting packages will allow using assertions on the full-state simulator
// to help build confidence in shared decompositions, further improving test
// coverage.

namespace Microsoft.Quantum.Experimental.Tests {
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Diagnostics;

    internal function Fact(expected : Bool, message : String) : Unit {
        if not expected {
            fail $"Fact was false: {message}";
        }
    }

    internal operation MX(target : Qubit) : Result {
        return Measure([PauliX], [target]);
    }

    @Test("Microsoft.Quantum.Experimental.OpenSystemsSimulator")
    operation CheckBellBasisParitiesWithSingleQubitMeasurements() : Unit {
        use (left, right) = (Qubit(), Qubit()) {
            H(left);
            CNOT(left, right);

            Fact(M(left) == M(right), "Z parity in 00 case was wrong.");
            ResetAll([left, right]);
        }

        use (left, right) = (Qubit(), Qubit()) {
            H(left);
            CNOT(left, right);

            Fact(MX(left) == MX(right), "X parity in 00 case was wrong.");
            ResetAll([left, right]);
        }

        use (left, right) = (Qubit(), Qubit()) {
            H(left);
            CNOT(left, right);

            X(left);

            Fact(M(left) != M(right), "Z parity in 10 case was wrong.");
            ResetAll([left, right]);
        }

        use (left, right) = (Qubit(), Qubit()) {
            H(left);
            CNOT(left, right);

            X(left);

            Fact(MX(left) == MX(right), "X parity in 10 case was wrong.");
            ResetAll([left, right]);
        }

        use (left, right) = (Qubit(), Qubit()) {
            H(left);
            CNOT(left, right);

            Z(left);

            Fact(M(left) == M(right), "Z parity in 01 case was wrong.");
            ResetAll([left, right]);
        }

        use (left, right) = (Qubit(), Qubit()) {
            H(left);
            CNOT(left, right);

            Z(left);

            Fact(MX(left) != MX(right), "X parity in 01 case was wrong.");
            ResetAll([left, right]);
        }

        use (left, right) = (Qubit(), Qubit()) {
            H(left);
            CNOT(left, right);

            X(left);
            Z(left);

            Fact(M(left) != M(right), "Z parity in 11 case was wrong.");
            ResetAll([left, right]);
        }

        use (left, right) = (Qubit(), Qubit()) {
            H(left);
            CNOT(left, right);

            X(left);
            Z(left);

            Fact(MX(left) != MX(right), "X parity in 11 case was wrong.");
            ResetAll([left, right]);
        }
    }

    internal function Xor(a : Bool, b : Bool) : Bool {
        return (a or b) and ((not a) or (not b));
    }

    @Test("Microsoft.Quantum.Experimental.OpenSystemsSimulator")
    @Test("QuantumSimulator") // validate against full-state simulator.
    operation CheckToffoliOnComputationalBasisStates() : Unit {
        for in0 in [false, true] {
            for in1 in [false, true] {
                for output in [false, true] {
                    for useCcz in [false, true] {
                        use qs = Qubit[3];
                        if in0 { X(qs[0]); }
                        if in1 { X(qs[1]); }
                        if output { X(qs[2]); }

                        let expectedOut = Xor(output, in0 and in1);

                        if useCcz {
                            within {
                                H(qs[2]);
                            } apply {
                                Controlled Z([qs[0], qs[1]], qs[2]);
                            }
                        } else {
                            Controlled X([qs[0], qs[1]], qs[2]);
                        }

                        let results = [M(qs[0]), M(qs[1]), M(qs[2])];
                        let expected = [in0 ? One | Zero, in1 ? One | Zero, expectedOut ? One | Zero];

                        Fact(results[0] == expected[0], $"in0 was incorrect in case: {in0} {in1} {output}. Got {results[0]}, expected {expected[0]}.");
                        Fact(results[1] == expected[1], $"in1 was incorrect in case: {in0} {in1} {output}. Got {results[1]}, expected {expected[1]}.");
                        Fact(results[2] == expected[2], $"expected was incorrect in case: {in0} {in1} {output}. Got {results[2]}, expected {expected[2]}.");

                        ResetAll(qs);
                    }
                }
            }
        }
    }

    @Test("Microsoft.Quantum.Experimental.OpenSystemsSimulator")
    @Test("QuantumSimulator") // validate against full-state simulator.
    operation CheckXHSZSHIsNoOp() : Unit {
        use q = Qubit();

        X(q);
        within {
            H(q);
            S(q);
        } apply {
            Z(q);
        }

        Fact(M(q) == Zero, "XHSZSH was not a no-op.");
    }

    @Test("Microsoft.Quantum.Experimental.OpenSystemsSimulator")
    @Test("QuantumSimulator") // validate against full-state simulator.
    operation CheckControlledHWorks() : Unit {
        use control = Qubit();
        use target = Qubit();


        Controlled H([control], target);
        within {
            X(control);
        } apply {
            Controlled H([control], target);
        }
        H(target);

        Fact(M(control) == Zero, "Controlled H did not work correctly.");
        Fact(M(target) == Zero, "Controlled H did not work correctly.");

    }

}

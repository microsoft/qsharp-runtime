// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.


namespace Microsoft.Quantum.Simulation.Testing.Honeywell.RepeatLoopLiftingTests {

    open Microsoft.Quantum.Intrinsic;

    operation DoNotLiftClassicalRepeat() : Unit {
        using (q = Qubit()) {
            let success = true;
            repeat {
                X(q);
            }
            until (success);
            Reset(q);
        }
    }

    operation LiftRepeatBody() : Unit {
        using (q = Qubit()) {
            repeat {
                H(q);
            }
            until (M(q) == One);
        }
    }

    operation LiftRepeatAndFixupBody() : Unit {
        using (q = Qubit()) {
            repeat {
                H(q);
            }
            until (M(q) == Zero)
            fixup {
                X(q);
            }
        }
    }

    operation LiftNestedRepeats() : Unit {
        using (q = Qubit()) {
            repeat {
                H(q);
                repeat {
                    X(q);
                }
                until (M(q) == One)
                fixup {
                    X(q);
                }
            }
            until (M(q) == One);
            X(q);
        }
    }

    operation LiftInnerRepeat() : Unit {
        using (q = Qubit()) {
            mutable count = 10;
            repeat {
                repeat {
                    H(q);
                }
                until (M(q) == Zero)
                fixup {
                    X(q);
                }
                set count = count - 1;
            }
            until (count == 0);
        }
    }

}

// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

// For the test to pass implement K to be the same as X. We need it for the test, because the standard bridge doesn't
// support multi-controlled X.
namespace Microsoft.Quantum.Intrinsic {
    open Microsoft.Quantum.Core;
    @Inline()
    operation K(q : Qubit) : Unit
    is Adj+Ctl {
        body intrinsic;
        adjoint self;
        controlled intrinsic;
    }
}

namespace Microsoft.Quantum.Testing.QIR {
    open Microsoft.Quantum.Intrinsic;

    operation Qop(q : Qubit, n : Int) : Unit
    is Adj+Ctl {
        body (...) {
            if n%2 == 1 { K(q); }
        }
        adjoint self;
        controlled (ctrls, ...) {
            if n%2 == 1 { Controlled K(ctrls, q); }
        }
    }

    // We want to test for conditional measurements which requires us to generate QIR with --runtime set to 
    // BasicMeasurementFeedback, which in turn doesn't allow updating mutables inside measurement conditionals.
    // this means, we cannot easily get detailed failure information back from Q#, but the test driver can mock
    // the simulator to track the point of failure.
    @EntryPoint()
    operation TestFunctors() : Unit {
        let qop = Qop(_, 1);
        let adj_qop = Adjoint qop;
        let ctl_qop = Controlled qop;
        let adj_ctl_qop = Adjoint Controlled qop;
        let ctl_ctl_qop = Controlled ctl_qop;

        use (q1, q2, q3) = (Qubit(), Qubit(), Qubit()) {
            qop(q1);
            if (M(q1) != One) { fail("error code: 1"); }
 
            adj_qop(q2);
            if (M(q2) != One) { fail("error code: 2"); }

            ctl_qop([q1], q3);
            if (M(q3) != One) { fail("error code: 3"); }

            adj_ctl_qop([q2], q3);
            if (M(q3) != Zero) { fail("error code: 2"); }

            ctl_ctl_qop([q1], ([q2], q3));
            if (M(q3) != One) { fail("error code: 5"); }

            Controlled qop([q1, q2], q3);
            if (M(q3) != Zero) { fail("error code: 6"); }

            use q4 = Qubit() {
                Adjoint qop(q3);
                Adjoint Controlled ctl_ctl_qop([q1], ([q2], ([q3], q4)));
                if (M(q4) != One) { fail("error code: 7"); }
            }
        }
    }

    // The operation is not sensical but in tests we can mock K operator to check that it actually executes
    operation NoArgs() : Unit
    is Adj+Ctl {
        body (...) {
            use q = Qubit();
            K(q);
        }
        adjoint self;
        controlled (ctrls, ...) {
            use q = Qubit();
            Controlled K(ctrls, q);
        }
    }

    @EntryPoint()
    operation TestFunctorsNoArgs() : Unit {
        NoArgs();
        let qop = NoArgs;
        let adj_qop = Adjoint qop;
        let ctl_qop = Controlled qop;
        let adj_ctl_qop = Adjoint Controlled qop;
        let ctl_ctl_qop = Controlled ctl_qop;

        use (q1, q2, q3) = (Qubit(), Qubit(), Qubit()) {
            X(q1);
            X(q2);
            X(q3);

            qop();
            adj_qop();
            ctl_qop([q1], ());
            adj_ctl_qop([q1], ());
            ctl_ctl_qop([q1], ([q2], ()));

            Controlled qop([q1, q2], ());
            Adjoint Controlled ctl_ctl_qop([q1], ([q2], ([q3], ())));
        }
    }
}
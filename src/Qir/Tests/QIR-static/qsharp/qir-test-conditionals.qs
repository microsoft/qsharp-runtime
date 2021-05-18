// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.
namespace Microsoft.Quantum.Testing.QIR {
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.ClassicalControl;

    @EntryPoint()
    operation TestApplyIf() : Unit {
        use q1 = Qubit();
        use q2 = Qubit();

        let r1 = M(q1); // expected: r1 = Zero
        X(q2);
        let r2 = M(q2); // expected: r2 = One

        ApplyIfElseR(r1, (X, q1), (Y, q1));
        ApplyIfElseR(r2, (Y, q1), (X, q1));

        // Other variants
        ApplyIfElseRA(r1, (X, q1), (Y, q1));
        ApplyIfElseRC(r1, (X, q1), (Y, q1));
        ApplyIfElseRCA(r1, (X, q1), (Y, q1));
        ApplyIfOne(r2, (X, q1));
        ApplyIfZero(r1, (X, q1));
    }

    @EntryPoint()
    operation TestApplyIfWithFunctors() : Unit {
        use q1 = Qubit();
        use q2 = Qubit();

        let r1 = M(q1);
        X(q2);
        let r2 = M(q2);

        Adjoint ApplyIfElseRCA(r1, (X, q1), (Y, q1));
        Controlled ApplyIfElseRCA([q2], (r1, (X, q1), (Y, q1)));
        Adjoint Controlled ApplyIfElseRCA([q2], (r1, (X, q1), (Y, q1)));
        Adjoint ApplyIfElseRA(r1, (X, q1), (Y, q1));
        Controlled ApplyIfElseRC([q2], (r1, (X, q1), (Y, q1)));
        Adjoint ApplyIfOneA(r2, (X, q1));
        Controlled ApplyIfOneC([q2], (r2, (X, q1)));
        Adjoint Controlled ApplyIfOneCA([q2], (r2, (X, q1)));
        Adjoint ApplyIfZeroA(r1, (X, q1));
        Controlled ApplyIfZeroC([q2], (r1, (X, q1)));
        Adjoint Controlled ApplyIfZeroCA([q2], (r1, (X, q1)));
    }

    @EntryPoint()
    operation TestApplyConditionally() : Unit {
        use q1 = Qubit();
        use q2 = Qubit();

        let r1 = M(q1);
        X(q2);
        let r2 = M(q2);

        ApplyConditionally([r1], [r2], (Y, q1), (X, q1));
        ApplyConditionally([r1, One], [Zero, r2], (X, q1), (Y, q1));

        Adjoint ApplyConditionallyA([r1], [r2], (Y, q1), (X, q1));
        Controlled ApplyConditionallyC([q2], ([r1], [r2], (Y, q1), (X, q1)));
        Adjoint Controlled ApplyConditionallyCA([q2], ([r1], [r2], (Y, q1), (X, q1)));
    }

}
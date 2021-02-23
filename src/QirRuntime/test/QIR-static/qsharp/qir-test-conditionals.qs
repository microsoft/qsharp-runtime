// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.
namespace Microsoft.Quantum.Testing.QIR {
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Canon;

    operation TestApplyIf() : Unit {
        use q1 = Qubit();
        use q2 = Qubit();

        // Zero branch
        let r1 = M(q1);
        ApplyIfElseRCA(r1, (X, q1), (Y, q1));
        Adjoint ApplyIfElseRCA(r1, (X, q1), (Y, q1));
        Controlled ApplyIfElseRCA([q2], (r1, (X, q1), (Y, q1)));
        X(q2);
        Adjoint Controlled ApplyIfElseRCA([q2], (r1, (X, q1), (Y, q1)));

        // One branch
        let r2 = M(q2);
        ApplyIfElseRCA(r2, (Y, q1), (X, q1));

        // Other variants
        ApplyIfElseR(r1, (X, q1), (Y, q1));
        Adjoint ApplyIfElseRA(r1, (X, q1), (Y, q1));
        Controlled ApplyIfElseRC([q2], (r1, (X, q1), (Y, q1)));

        ApplyIfOne(r2, (X, q1));
        Adjoint ApplyIfOneA(r2, (X, q1));
        Controlled ApplyIfOneC([q2], (r2, (X, q1)));
        Adjoint Controlled ApplyIfOneCA([q2], (r2, (X, q1)));

        ApplyIfZero(r1, (X, q1));
        Adjoint ApplyIfZeroA(r1, (X, q1));
        Controlled ApplyIfZeroC([q2], (r1, (X, q1)));
        Adjoint Controlled ApplyIfZeroCA([q2], (r1, (X, q1)));
    }

    operation TestApplyConditionally() : Unit {
        use q1 = Qubit();
        use q2 = Qubit();

        let r1 = M(q1);
        X(q2);
        let r2 = M(q2);

        Microsoft.Quantum.Simulation.QuantumProcessor.Extensions.ApplyConditionally([r1], [r2], (Y, q1), (X, q1));
        Microsoft.Quantum.Simulation.QuantumProcessor.Extensions.ApplyConditionally(
            [r1, One], [Zero, r2], (X, q1), (Y, q1));

        // Other variants
        Adjoint Microsoft.Quantum.Simulation.QuantumProcessor.Extensions.ApplyConditionallyA(
            [r1], [r2], (Y, q1), (X, q1));
        Controlled Microsoft.Quantum.Simulation.QuantumProcessor.Extensions.ApplyConditionallyC(
            [q2], ([r1], [r2], (Y, q1), (X, q1)));
        Adjoint Controlled Microsoft.Quantum.Simulation.QuantumProcessor.Extensions.ApplyConditionallyCA(
            [q2], ([r1], [r2], (Y, q1), (X, q1)));
    }

    operation TestConditionalRewrite() : Unit {
        use q1 = Qubit();
        use q2 = Qubit();

        if M(q1) == Zero {
            X(q1);
            Controlled X([q2], q1);
        }
        else {
            Y(q1);
        }
    }
}
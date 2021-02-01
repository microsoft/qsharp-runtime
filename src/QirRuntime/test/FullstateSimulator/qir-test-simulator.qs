// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

// This test uses all operations from the quantum instruction set that targets full state simulator.
// We are not validating the result, only that the test can compile and run against the simulator.
namespace Microsoft.Quantum.Testing.QIR
{
    open Microsoft.Quantum.Intrinsic;

    operation InvokeAllVariants(op : (Qubit => Unit is Adj + Ctl)) : Unit
    {
        using((target, ctls) = (Qubit(), Qubit[2]))
        {
            op(target);
            Adjoint op(target);
            Controlled op(ctls, target);
            Adjoint Controlled op(ctls, target);
        }
    }

    @EntryPoint()
    operation Test_Simulator_QIS() : Unit
    {
        InvokeAllVariants(X);
        InvokeAllVariants(Y);
        InvokeAllVariants(Z);
        InvokeAllVariants(H);
        InvokeAllVariants(S);
        InvokeAllVariants(T);
        InvokeAllVariants(R(PauliX, 0.42, _));

        using((targets, ctls) = (Qubit[2], Qubit[2]))
        {
            let theta = 0.42;
            Exp([PauliX, PauliY], theta, targets);
            Adjoint Exp([PauliX, PauliY], theta, targets);
            Controlled Exp(ctls, ([PauliX, PauliY], theta, targets));
            Adjoint Controlled Exp(ctls, ([PauliX, PauliY], theta, targets));
        }

        using(qs = Qubit[3])
        {
            let res = Measure([PauliX, PauliY, PauliZ], qs);
        }
    }
}

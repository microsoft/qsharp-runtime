// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Intrinsic.Interfaces
{
    public interface IGate_Exp : IOperationFactory
    {
        void Exp_Body(IQArray<Pauli> paulis, double angle, IQArray<Qubit> targets);

        void Exp_AdjointBody(IQArray<Pauli> paulis, double angle, IQArray<Qubit> targets);

        void Exp_ControlledBody(IQArray<Qubit> controls, IQArray<Pauli> paulis, double angle, IQArray<Qubit> targets);

        void Exp_ControlledAdjointBody(IQArray<Qubit> controls, IQArray<Pauli> paulis, double angle, IQArray<Qubit> targets);
    }
}
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Intrinsic.Interfaces
{
    public interface IGate_Exp : IOperationFactory
    {
        void Exp__Body(IQArray<Pauli> paulis, double angle, IQArray<Qubit> targets);

        void Exp__AdjointBody(IQArray<Pauli> paulis, double angle, IQArray<Qubit> targets);

        void Exp__ControlledBody(IQArray<Qubit> controls, IQArray<Pauli> paulis, double angle, IQArray<Qubit> targets);

        void Exp__ControlledAdjointBody(IQArray<Qubit> controls, IQArray<Pauli> paulis, double angle, IQArray<Qubit> targets);
    }
}
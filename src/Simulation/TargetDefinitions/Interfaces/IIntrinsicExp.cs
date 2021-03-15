// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Intrinsic.Interfaces
{
    public interface IIntrinsicExp : IOperationFactory
    {
        void Body(IQArray<Pauli> paulis, double angle, IQArray<Qubit> targets);

        void AdjointBody(IQArray<Pauli> paulis, double angle, IQArray<Qubit> targets);

        void ControlledBody(IQArray<Qubit> controls, IQArray<Pauli> paulis, double angle, IQArray<Qubit> targets);

        void ControlledAdjointBody(IQArray<Qubit> controls, IQArray<Pauli> paulis, double angle, IQArray<Qubit> targets);
    }
}
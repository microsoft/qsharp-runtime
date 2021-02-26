// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Intrinsic.Interfaces
{
    public interface IIntrinsicR : IOperationFactory
    {
        void Body(Pauli pauli, double angle, Qubit target);

        void AdjointBody(Pauli pauli, double angle, Qubit target);

        void ControlledBody(IQArray<Qubit> controls, Pauli pauli, double angle, Qubit target);

        void ControlledAdjointBody(IQArray<Qubit> controls, Pauli pauli, double angle, Qubit target);
    }
}
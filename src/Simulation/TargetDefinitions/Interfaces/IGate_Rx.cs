// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Intrinsic.Interfaces
{
    public interface IIntrinsicRx : IOperationFactory
    {
        void Body(double angle, Qubit target);

        void AdjointBody(double angle, Qubit target);

        void ControlledBody(IQArray<Qubit> controls, double angle, Qubit target);

        void ControlledAdjointBody(IQArray<Qubit> controls, double angle, Qubit target);
    }
}
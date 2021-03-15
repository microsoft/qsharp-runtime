// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Intrinsic.Interfaces
{
    public interface IIntrinsicS : IOperationFactory
    {
        void Body(Qubit target);

        void AdjointBody(Qubit target);

        void ControlledBody(IQArray<Qubit> controls, Qubit target);

        void ControlledAdjointBody(IQArray<Qubit> controls, Qubit target);
    }
}
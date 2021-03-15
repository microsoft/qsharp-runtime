// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Intrinsic.Interfaces
{
    public interface IIntrinsicY : IOperationFactory
    {
        void Body(Qubit target);

        void ControlledBody(IQArray<Qubit> controls, Qubit target);
    }
}
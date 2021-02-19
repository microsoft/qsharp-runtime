// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Intrinsic.Interfaces
{
    public interface IGate_Z : IOperationFactory
    {
        void Z__Body(Qubit target);

        void Z__ControlledBody(IQArray<Qubit> controls, Qubit target);
    }
}
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Intrinsic.Interfaces
{
    public interface IGate_X : IOperationFactory
    {
        void X__Body(Qubit target);

        void X__ControlledBody(IQArray<Qubit> controls, Qubit target);
    }
}
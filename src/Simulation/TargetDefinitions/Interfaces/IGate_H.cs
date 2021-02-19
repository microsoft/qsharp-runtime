// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Intrinsic.Interfaces
{
    public interface IGate_H : IOperationFactory
    {
        void H__Body(Qubit target);

        void H__ControlledBody(IQArray<Qubit> controls, Qubit target);
    }
}
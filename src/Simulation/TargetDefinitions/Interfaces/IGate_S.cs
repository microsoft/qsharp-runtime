// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Intrinsic.Interfaces
{
    public interface IGate_S : IOperationFactory
    {
        void S__Body(Qubit target);

        void S__AdjointBody(Qubit target);

        void S__ControlledBody(IQArray<Qubit> controls, Qubit target);

        void S__ControlledAdjointBody(IQArray<Qubit> controls, Qubit target);
    }
}
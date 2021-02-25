// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Intrinsic.Interfaces
{
    public interface IGate_T : IOperationFactory
    {
        void T__Body(Qubit target);

        void T__AdjointBody(Qubit target);

        void T__ControlledBody(IQArray<Qubit> controls, Qubit target);

        void T__ControlledAdjointBody(IQArray<Qubit> controls, Qubit target);
    }
}
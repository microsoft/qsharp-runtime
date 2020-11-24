// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Intrinsic.Interfaces
{
    public interface IGate_S : IOperationFactory
    {
        void S_Body(Qubit target);

        void S_AdjointBody(Qubit target);

        void S_ControlledBody(IQArray<Qubit> controls, Qubit target);

        void S_ControlledAdjointBody(IQArray<Qubit> controls, Qubit target);
    }
}
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Intrinsic.Interfaces
{
    public interface IGate_S : IOperationFactory
    {
        Func<Qubit, QVoid> S_Body();

        Func<Qubit, QVoid> S_AdjointBody();

        Func<(IQArray<Qubit>, Qubit), QVoid> S_ControlledBody();

        Func<(IQArray<Qubit>, Qubit), QVoid> S_ControlledAdjointBody();
    }
}
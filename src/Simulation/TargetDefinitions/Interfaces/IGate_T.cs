// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Intrinsic.Interfaces
{
    public interface IGate_T : IOperationFactory
    {
        Func<Qubit, QVoid> T_Body();

        Func<Qubit, QVoid> T_AdjointBody();

        Func<(IQArray<Qubit>, Qubit), QVoid> T_ControlledBody();

        Func<(IQArray<Qubit>, Qubit), QVoid> T_ControlledAdjointBody();
    }
}
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Intrinsic.Interfaces
{
    public interface IGate_Y : IOperationFactory
    {
        Func<Qubit, QVoid> Y_Body();

        Func<(IQArray<Qubit>, Qubit), QVoid> Y_ControlledBody();
    }
}
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Intrinsic.Interfaces
{
    public interface IGate_SWAP : IOperationFactory
    {
        Func<(Qubit, Qubit), QVoid> SWAP_Body();

        Func<(IQArray<Qubit>, (Qubit, Qubit)), QVoid> SWAP_ControlledBody();
    }
}
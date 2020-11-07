// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Intrinsic.Interfaces
{
    public interface IGate_Rx : IOperationFactory
    {
        Func<(double, Qubit), QVoid> Rx_Body();

        Func<(double, Qubit), QVoid> Rx_AdjointBody();

        Func<(IQArray<Qubit>, (double, Qubit)), QVoid> Rx_ControlledBody();

        Func<(IQArray<Qubit>, (double, Qubit)), QVoid> Rx_ControlledAdjointBody();
    }
}
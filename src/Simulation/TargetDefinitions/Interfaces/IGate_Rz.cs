// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Intrinsic.Interfaces
{
    public interface IGate_Rz : IOperationFactory
    {
        Func<(double, Qubit), QVoid> Rz_Body();

        Func<(double, Qubit), QVoid> Rz_AdjointBody();

        Func<(IQArray<Qubit>, (double, Qubit)), QVoid> Rz_ControlledBody();

        Func<(IQArray<Qubit>, (double, Qubit)), QVoid> Rz_ControlledAdjointBody();
    }
}
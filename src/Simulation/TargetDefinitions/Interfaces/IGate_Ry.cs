// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Intrinsic.Interfaces
{
    public interface IGate_Ry : IOperationFactory
    {
        Func<(double, Qubit), QVoid> Ry_Body();

        Func<(double, Qubit), QVoid> Ry_AdjointBody();

        Func<(IQArray<Qubit>, (double, Qubit)), QVoid> Ry_ControlledBody();

        Func<(IQArray<Qubit>, (double, Qubit)), QVoid> Ry_ControlledAdjointBody();
    }
}
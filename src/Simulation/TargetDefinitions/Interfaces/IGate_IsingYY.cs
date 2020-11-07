// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Intrinsic.Interfaces
{
    public interface IGate_IsingYY : IOperationFactory
    {
        Func<(double, Qubit, Qubit), QVoid> IsingYY_Body();

        Func<(double, Qubit, Qubit), QVoid> IsingYY_AdjointBody();

        Func<(IQArray<Qubit>, (double, Qubit, Qubit)), QVoid> IsingYY_ControlledBody();

        Func<(IQArray<Qubit>, (double, Qubit, Qubit)), QVoid> IsingYY_ControlledAdjointBody();
    }
}
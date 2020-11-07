// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Intrinsic.Interfaces
{
    public interface IGate_R : IOperationFactory
    {
        Func<(Pauli, double, Qubit), QVoid> R_Body();

        Func<(Pauli, double, Qubit), QVoid> R_AdjointBody();

        Func<(IQArray<Qubit>, (Pauli, double, Qubit)), QVoid> R_ControlledBody();

        Func<(IQArray<Qubit>, (Pauli, double, Qubit)), QVoid> R_ControlledAdjointBody();
    }
}
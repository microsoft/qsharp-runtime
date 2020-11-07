// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Intrinsic.Interfaces
{
    public interface IGate_Exp : IOperationFactory
    {
        Func<(IQArray<Pauli>, double, IQArray<Qubit>), QVoid> Exp_Body();

        Func<(IQArray<Pauli>, double, IQArray<Qubit>), QVoid> Exp_AdjointBody();

        Func<(IQArray<Qubit>, (IQArray<Pauli>, double, IQArray<Qubit>)), QVoid> Exp_ControlledBody();

        Func<(IQArray<Qubit>, (IQArray<Pauli>, double, IQArray<Qubit>)), QVoid> Exp_ControlledAdjointBody();
    }
}
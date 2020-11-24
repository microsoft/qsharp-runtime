// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Intrinsic.Interfaces
{
    public interface IGate_R : IOperationFactory
    {
        void R_Body(Pauli pauli, double angle, Qubit target);

        void R_AdjointBody(Pauli pauli, double angle, Qubit target);

        void R_ControlledBody(IQArray<Qubit> controls, Pauli pauli, double angle, Qubit target);

        void R_ControlledAdjointBody(IQArray<Qubit> controls, Pauli pauli, double angle, Qubit target);
    }
}
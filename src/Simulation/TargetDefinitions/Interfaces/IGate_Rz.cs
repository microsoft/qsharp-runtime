// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Intrinsic.Interfaces
{
    public interface IGate_Rz : IOperationFactory
    {
        void Rz_Body(double angle, Qubit target);

        void Rz_AdjointBody(double angle, Qubit target);

        void Rz_ControlledBody(IQArray<Qubit> controls, double angle, Qubit target);

        void Rz_ControlledAdjointBody(IQArray<Qubit> controls, double angle, Qubit target);
    }
}
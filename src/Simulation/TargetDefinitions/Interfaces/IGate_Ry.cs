// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Intrinsic.Interfaces
{
    public interface IGate_Ry : IOperationFactory
    {
        void Ry_Body(double angle, Qubit target);

        void Ry_AdjointBody(double angle, Qubit target);

        void Ry_ControlledBody(IQArray<Qubit> controls, double angle, Qubit target);

        void Ry_ControlledAdjointBody(IQArray<Qubit> controls, double angle, Qubit target);
    }
}
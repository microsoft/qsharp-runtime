// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Intrinsic.Interfaces
{
    public interface IGate_Ry : IOperationFactory
    {
        void Ry__Body(double angle, Qubit target);

        void Ry__AdjointBody(double angle, Qubit target);

        void Ry__ControlledBody(IQArray<Qubit> controls, double angle, Qubit target);

        void Ry__ControlledAdjointBody(IQArray<Qubit> controls, double angle, Qubit target);
    }
}
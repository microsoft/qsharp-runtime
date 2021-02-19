// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Intrinsic.Interfaces
{
    public interface IGate_Rx : IOperationFactory
    {
        void Rx__Body(double angle, Qubit target);

        void Rx__AdjointBody(double angle, Qubit target);

        void Rx__ControlledBody(IQArray<Qubit> controls, double angle, Qubit target);

        void Rx__ControlledAdjointBody(IQArray<Qubit> controls, double angle, Qubit target);
    }
}
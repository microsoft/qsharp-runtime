// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Intrinsic.Interfaces
{
    public interface IGate_IsingZZ : IOperationFactory
    {
        void IsingZZ__Body(double angle, Qubit target1, Qubit target2);

        void IsingZZ__AdjointBody(double angle, Qubit target1, Qubit target2);

        void IsingZZ__ControlledBody(IQArray<Qubit> controls, double angle, Qubit target1, Qubit target2);

        void IsingZZ__ControlledAdjointBody(IQArray<Qubit> controls, double angle, Qubit target1, Qubit target2);
    }
}
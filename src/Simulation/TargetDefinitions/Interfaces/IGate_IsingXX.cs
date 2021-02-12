// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Intrinsic.Interfaces
{
    public interface IGate_IsingXX : IOperationFactory
    {
        void IsingXX__Body(double angle, Qubit target1, Qubit target2);

        void IsingXX__AdjointBody(double angle, Qubit target1, Qubit target2);

        void IsingXX__ControlledBody(IQArray<Qubit> controls, double angle, Qubit target1, Qubit target2);

        void IsingXX__ControlledAdjointBody(IQArray<Qubit> controls, double angle, Qubit target1, Qubit target2);
    }
}
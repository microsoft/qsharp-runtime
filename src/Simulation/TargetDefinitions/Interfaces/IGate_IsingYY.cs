// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Intrinsic.Interfaces
{
    public interface IIntrinsicIsingYY : IOperationFactory
    {
        void Body(double angle, Qubit target1, Qubit target2);

        void AdjointBody(double angle, Qubit target1, Qubit target2);

        void ControlledBody(IQArray<Qubit> controls, double angle, Qubit target1, Qubit target2);

        void ControlledAdjointBody(IQArray<Qubit> controls, double angle, Qubit target1, Qubit target2);
    }
}
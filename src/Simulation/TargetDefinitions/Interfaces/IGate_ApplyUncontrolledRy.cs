// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Intrinsic.Interfaces
{
    public interface IGate_ApplyUncontrolledRy : IOperationFactory
    {
        void ApplyUncontrolledRy__Body(double angle, Qubit target);

        void ApplyUncontrolledRy__AdjointBody(double angle, Qubit target);
    }
}
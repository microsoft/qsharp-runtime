// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Intrinsic.Interfaces
{
    public interface IGate_ApplyUncontrolledRz : IOperationFactory
    {
        void ApplyUncontrolledRz__Body(double angle, Qubit target);

        void ApplyUncontrolledRz__AdjointBody(double angle, Qubit target);
    }
}
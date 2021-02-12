// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Intrinsic.Interfaces
{
    public interface IGate_ApplyUncontrolledT : IOperationFactory
    {
        void ApplyUncontrolledT__Body(Qubit target);

        void ApplyUncontrolledT__AdjointBody(Qubit target);
    }
}
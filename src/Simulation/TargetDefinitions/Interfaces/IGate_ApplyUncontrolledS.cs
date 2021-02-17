// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Intrinsic.Interfaces
{
    public interface IGate_ApplyUncontrolledS : IOperationFactory
    {
        void ApplyUncontrolledS__Body(Qubit target);

        void ApplyUncontrolledS__AdjointBody(Qubit target);
    }
}
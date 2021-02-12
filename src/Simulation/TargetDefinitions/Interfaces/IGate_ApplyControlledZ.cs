// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Intrinsic.Interfaces
{
    public interface IGate_ApplyControlledZ : IOperationFactory
    {
        void ApplyControlledZ__Body(Qubit control, Qubit target);
    }
}
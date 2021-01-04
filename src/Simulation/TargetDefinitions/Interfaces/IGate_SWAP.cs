// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Intrinsic.Interfaces
{
    public interface IGate_SWAP : IOperationFactory
    {
        void SWAP__Body(Qubit target1, Qubit target2);

        void SWAP__ControlledBody(IQArray<Qubit> controls, Qubit target1, Qubit target2);
    }
}
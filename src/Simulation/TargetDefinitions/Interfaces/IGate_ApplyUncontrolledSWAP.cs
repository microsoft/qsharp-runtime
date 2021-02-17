// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Intrinsic.Interfaces
{
    public interface IGate_ApplyUncontrolledSWAP : IOperationFactory
    {
        void ApplyUncontrolledSWAP__Body(Qubit qubit1, Qubit qubit2);
    }
}
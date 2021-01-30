// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Intrinsic.Interfaces
{
    public interface IGate_Measure : IOperationFactory
    {
        Result Measure__Body(IQArray<Pauli> paulis, IQArray<Qubit> targets);
    }
}
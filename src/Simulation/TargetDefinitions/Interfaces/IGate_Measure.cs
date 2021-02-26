// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Intrinsic.Interfaces
{
    public interface IIntrinsicMeasure : IOperationFactory
    {
        Result Body(IQArray<Pauli> paulis, IQArray<Qubit> targets);
    }
}
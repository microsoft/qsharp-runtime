// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Intrinsic.Interfaces
{
    public interface IGate_ApplyUncontrolledZ : IOperationFactory
    {
        Func<Qubit, QVoid> ApplyUncontrolledZ_Body();
    }
}
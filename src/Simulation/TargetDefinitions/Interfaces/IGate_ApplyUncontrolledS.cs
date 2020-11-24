// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Intrinsic.Interfaces
{
    public interface IGate_ApplyUncontrolledS : IOperationFactory
    {
        void ApplyUncontrolledS_Body(Qubit target);

        void ApplyUncontrolledS_AdjointBody(Qubit target);
    }
}
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Intrinsic.Interfaces
{
    public interface IGate_ApplyUncontrolledT : IOperationFactory
    {
        void ApplyUncontrolledT_Body(Qubit target);

        void ApplyUncontrolledT_AdjointBody(Qubit target);
    }
}
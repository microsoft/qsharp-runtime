// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Intrinsic.Interfaces
{
    public interface IGate_ApplyUncontrolledRx : IOperationFactory
    {
        void ApplyUncontrolledRx_Body(double angle, Qubit target);

        void ApplyUncontrolledRx_AdjointBody(double angle, Qubit target);
    }
}
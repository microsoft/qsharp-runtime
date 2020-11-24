// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Intrinsic.Interfaces
{
    public interface IGate_ApplyUncontrolledRz : IOperationFactory
    {
        void ApplyUncontrolledRz_Body(double angle, Qubit target);

        void ApplyUncontrolledRz_AdjointBody(double angle, Qubit target);
    }
}
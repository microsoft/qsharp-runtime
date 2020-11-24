// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Intrinsic.Interfaces
{
    public interface IGate_Z : IOperationFactory
    {
        void Z_Body(Qubit target);

        void Z_ControlledBody(IQArray<Qubit> controls, Qubit target);
    }
}
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Intrinsic.Interfaces
{
    public interface IGate_T : IOperationFactory
    {
        void T_Body(Qubit target);

        void T_AdjointBody(Qubit target);

        void T_ControlledBody(IQArray<Qubit> controls, Qubit target);

        void T_ControlledAdjointBody(IQArray<Qubit> controls, Qubit target);
    }
}
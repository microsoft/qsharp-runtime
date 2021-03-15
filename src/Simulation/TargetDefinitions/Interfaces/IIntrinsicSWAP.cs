// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Intrinsic.Interfaces
{
    public interface IIntrinsicSWAP : IOperationFactory
    {
        void Body(Qubit target1, Qubit target2);

        void ControlledBody(IQArray<Qubit> controls, Qubit target1, Qubit target2);
    }
}
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Intrinsic.Interfaces
{
    public interface IIntrinsicApplyUncontrolledRy : IOperationFactory
    {
        void Body(double angle, Qubit target);
    }
}
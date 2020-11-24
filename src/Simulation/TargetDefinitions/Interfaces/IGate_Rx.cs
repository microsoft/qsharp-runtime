// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Intrinsic.Interfaces
{
    public interface IGate_Rx : IOperationFactory
    {
        void Rx_Body(double angle, Qubit target);

        void Rx_AdjointBody(double angle, Qubit target);

        void Rx_ControlledBody(IQArray<Qubit> controls, double angle, Qubit target);

        void Rx_ControlledAdjointBody(IQArray<Qubit> controls, double angle, Qubit target);
    }
}
﻿// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Intrinsic.Interfaces;

namespace Microsoft.Quantum.Simulation.Simulators
{
    public partial class QuantumSimulator
    {
        void IIntrinsicApplyUncontrolledT.Body(Qubit target)
        {
            this.CheckQubit(target);

            T(this.Id, (uint)target.Id);
        }

        void IIntrinsicApplyUncontrolledT.AdjointBody(Qubit target)
        {
            this.CheckQubit(target);

            AdjT(this.Id, (uint)target.Id);
        }
    }
}

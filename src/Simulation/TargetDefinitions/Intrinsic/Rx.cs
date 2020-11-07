// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Intrinsic.Interfaces;

namespace Microsoft.Quantum.Intrinsic
{

    public partial class TargetIntrinsics
    {
        public class Shim_Rx : Rx
        {
            private IGate_Rx Gate { get; }

            public Shim_Rx(IGate_Rx g) : base(g)
            {
                this.Gate = g;
            }

            public override Func<(double, Qubit), QVoid> __Body__ => Gate.Rx_Body();

            public override Func<(double, Qubit), QVoid> __AdjointBody__ => Gate.Rx_AdjointBody();

            public override Func<(IQArray<Qubit>, (double, Qubit)), QVoid> __ControlledBody__ => Gate.Rx_ControlledBody();

            public override Func<(IQArray<Qubit>, (double, Qubit)), QVoid> __ControlledAdjointBody__ => Gate.Rx_ControlledAdjointBody();
        }
    }
}

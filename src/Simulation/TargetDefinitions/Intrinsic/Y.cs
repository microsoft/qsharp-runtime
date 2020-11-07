// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Intrinsic.Interfaces;

namespace Microsoft.Quantum.Intrinsic
{
    public partial class TargetIntrinsics
    {
        public class Shim_Y : Y
        {
            private IGate_Y Gate { get; }

            public Shim_Y(IGate_Y g) : base(g)
            {
                this.Gate = g;
            }

            public override Func<Qubit, QVoid> __Body__ => Gate.Y_Body();

            public override Func<(IQArray<Qubit>, Qubit), QVoid> __ControlledBody__ => Gate.Y_ControlledBody();
        }
    }
}

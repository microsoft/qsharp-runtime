// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Intrinsic.Interfaces;

namespace Microsoft.Quantum.Intrinsic
{

    public partial class TargetIntrinsics
    {
        internal class Shim_ApplyUncontrolledRx : ApplyUncontrolledRx
        {
            private IGate_ApplyUncontrolledRx Gate { get; }

            public Shim_ApplyUncontrolledRx(IGate_ApplyUncontrolledRx g) : base(g)
            {
                this.Gate = g;
            }

            public override Func<(double, Qubit), QVoid> __Body__ => Gate.ApplyUncontrolledRx_Body();

            public override Func<(double, Qubit), QVoid> __AdjointBody__ => Gate.ApplyUncontrolledRx_AdjointBody();
        }
    }
}

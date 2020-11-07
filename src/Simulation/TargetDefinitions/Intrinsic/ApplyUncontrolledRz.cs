// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Intrinsic.Interfaces;

namespace Microsoft.Quantum.Intrinsic
{

    public partial class TargetIntrinsics
    {
        internal class Shim_ApplyUncontrolledRz : ApplyUncontrolledRz
        {
            private IGate_ApplyUncontrolledRz Gate { get; }

            public Shim_ApplyUncontrolledRz(IGate_ApplyUncontrolledRz g) : base(g)
            {
                this.Gate = g;
            }

            public override Func<(double, Qubit), QVoid> __Body__ => Gate.ApplyUncontrolledRz_Body();

            public override Func<(double, Qubit), QVoid> __AdjointBody__ => Gate.ApplyUncontrolledRz_AdjointBody();
        }
    }
}

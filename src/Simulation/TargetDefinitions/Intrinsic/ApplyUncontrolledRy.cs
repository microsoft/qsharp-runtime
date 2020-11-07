// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Intrinsic.Interfaces;

namespace Microsoft.Quantum.Intrinsic
{

    public partial class TargetIntrinsics
    {
        internal class Shim_ApplyUncontrolledRy : ApplyUncontrolledRy
        {
            private IGate_ApplyUncontrolledRy Gate { get; }

            public Shim_ApplyUncontrolledRy(IGate_ApplyUncontrolledRy g) : base(g)
            {
                this.Gate = g;
            }

            public override Func<(double, Qubit), QVoid> __Body__ => Gate.ApplyUncontrolledRy_Body();

            public override Func<(double, Qubit), QVoid> __AdjointBody__ => Gate.ApplyUncontrolledRy_AdjointBody();
        }
    }
}

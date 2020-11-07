// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Intrinsic.Interfaces;

namespace Microsoft.Quantum.Intrinsic
{
    public partial class TargetIntrinsics
    {
        internal class Shim_ApplyControlledX : ApplyControlledX
        {
            private IGate_ApplyControlledX Gate { get; }

            public Shim_ApplyControlledX(IGate_ApplyControlledX g) : base(g)
            {
                this.Gate = g;
            }

            public override Func<(Qubit, Qubit), QVoid> __Body__ => Gate.ApplyControlledX_Body();
        }
    }
}

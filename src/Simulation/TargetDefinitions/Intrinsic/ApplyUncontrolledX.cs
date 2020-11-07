// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Intrinsic.Interfaces;

namespace Microsoft.Quantum.Intrinsic
{
    public partial class TargetIntrinsics
    {
        internal class Shim_ApplyUncontrolledX : ApplyUncontrolledX
        {
            private IGate_ApplyUncontrolledX Gate { get; }


            public Shim_ApplyUncontrolledX(IGate_ApplyUncontrolledX g) : base(g)
            {
                this.Gate = g;
            }

            public override Func<Qubit, QVoid> __Body__ => Gate.ApplyUncontrolledX_Body();
        }
    }
}

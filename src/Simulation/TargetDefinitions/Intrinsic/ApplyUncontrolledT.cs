// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Intrinsic.Interfaces;

namespace Microsoft.Quantum.Intrinsic
{
    public partial class TargetIntrinsics
    {
        internal class Shim_ApplyUncontrolledT : ApplyUncontrolledT
        {
            private IGate_ApplyUncontrolledT Gate { get; }

            public Shim_ApplyUncontrolledT(IGate_ApplyUncontrolledT g) : base(g)
            {
                this.Gate = g;
            }

            public override Func<Qubit, QVoid> __Body__ => Gate.ApplyUncontrolledT_Body();

            public override Func<Qubit, QVoid> __AdjointBody__ => Gate.ApplyUncontrolledT_AdjointBody();
        }
    }
}

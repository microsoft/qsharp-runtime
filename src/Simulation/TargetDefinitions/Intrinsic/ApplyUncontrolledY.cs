// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Intrinsic.Interfaces;

namespace Microsoft.Quantum.Intrinsic
{
    public partial class TargetIntrinsics
    {
        internal class Shim_ApplyUncontrolledY : ApplyUncontrolledY
        {
            private IGate_ApplyUncontrolledY Gate { get; }

            public Shim_ApplyUncontrolledY(IGate_ApplyUncontrolledY g) : base(g)
            {
                this.Gate = g;
            }

            public override Func<Qubit, QVoid> __Body__ => (target) =>
            {
                Gate.ApplyUncontrolledY_Body(target);
                return QVoid.Instance;
            };
        }
    }
}

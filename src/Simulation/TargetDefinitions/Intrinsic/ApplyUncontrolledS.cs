// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Intrinsic.Interfaces;

namespace Microsoft.Quantum.Intrinsic
{
    public partial class TargetIntrinsics
    {
        internal class Shim_ApplyUncontrolledS : ApplyUncontrolledS
        {
            private IGate_ApplyUncontrolledS Gate { get; }

            public Shim_ApplyUncontrolledS(IGate_ApplyUncontrolledS g) : base(g)
            {
                this.Gate = g;
            }

            public override Func<Qubit, QVoid> __Body__ => (target) =>
            {
                Gate.ApplyUncontrolledS_Body(target);
                return QVoid.Instance;
            };

            public override Func<Qubit, QVoid> __AdjointBody__ => (target) =>
            {
                Gate.ApplyUncontrolledS_AdjointBody(target);
                return QVoid.Instance;
            };
        }
    }
}

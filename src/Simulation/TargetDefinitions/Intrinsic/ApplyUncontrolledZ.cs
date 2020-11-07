// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Intrinsic.Interfaces;

namespace Microsoft.Quantum.Intrinsic
{
    public partial class TargetIntrinsics
    {
        internal class Shim_ApplyUncontrolledZ : ApplyUncontrolledZ
        {
            private IGate_ApplyUncontrolledZ Gate { get; }


            public Shim_ApplyUncontrolledZ(IGate_ApplyUncontrolledZ g) : base(g)
            {
                this.Gate = g;
            }

            public override Func<Qubit, QVoid> __Body__ => Gate.ApplyUncontrolledZ_Body();
        }
    }
}

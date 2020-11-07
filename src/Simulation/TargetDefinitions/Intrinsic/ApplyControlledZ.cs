// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Intrinsic.Interfaces;

namespace Microsoft.Quantum.Intrinsic
{
    public partial class TargetIntrinsics
    {
        internal class Shim_ApplyControlledZ : ApplyControlledZ
        {
            private IGate_ApplyControlledZ Gate { get; }

            public Shim_ApplyControlledZ(IGate_ApplyControlledZ g) : base(g)
            {
                this.Gate = g;
            }

            public override Func<(Qubit, Qubit), QVoid> __Body__ => Gate.ApplyControlledZ_Body();
        }
    }
}

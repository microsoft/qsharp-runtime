// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Intrinsic.Interfaces;

namespace Microsoft.Quantum.Intrinsic
{
    public partial class TargetIntrinsics
    {
        public class Shim_M : Quantum.Intrinsic.M
        {
            private IGate_M Gate { get; }

            public Shim_M(IGate_M g) : base(g)
            {
                this.Gate = g;
            }

            public override Func<Qubit, Result> __Body__ => (target) =>
            {
                return Gate.M_Body(target);
            };
        }
    }
}

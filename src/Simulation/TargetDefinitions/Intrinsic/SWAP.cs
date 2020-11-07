// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Intrinsic.Interfaces;

namespace Microsoft.Quantum.Intrinsic
{

    public partial class TargetIntrinsics
    {
        public class Shim_SWAP : SWAP
        {
            private IGate_SWAP Gate { get; }

            public Shim_SWAP(IGate_SWAP g) : base(g)
            {
                this.Gate = g;
            }

            public override Func<(Qubit, Qubit), QVoid> __Body__ => Gate.SWAP_Body();

            public override Func<(IQArray<Qubit>, (Qubit, Qubit)), QVoid> __ControlledBody__ => Gate.SWAP_ControlledBody();

        }
    }
}

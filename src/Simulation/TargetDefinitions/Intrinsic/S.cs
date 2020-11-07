// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Intrinsic.Interfaces;

namespace Microsoft.Quantum.Intrinsic
{
    public partial class TargetIntrinsics
    {
        public class Shim_S : S
        {
            private IGate_S Gate { get; }

            public Shim_S(IGate_S g) : base(g)
            {
                this.Gate = g;
            }

            public override Func<Qubit, QVoid> __Body__ => Gate.S_Body();

            public override Func<(IQArray<Qubit>, Qubit), QVoid> __ControlledBody__ => Gate.S_ControlledBody();

            public override Func<Qubit, QVoid> __AdjointBody__ => Gate.S_AdjointBody();

            public override Func<(IQArray<Qubit>, Qubit), QVoid> __ControlledAdjointBody__ => Gate.S_ControlledAdjointBody();
        }
    }
}

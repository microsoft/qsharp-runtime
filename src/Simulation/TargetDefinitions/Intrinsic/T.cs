// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Intrinsic.Interfaces;

namespace Microsoft.Quantum.Intrinsic
{
    public partial class TargetIntrinsics
    {
        public class Shim_T : T
        {
            private IGate_T Gate { get; }

            public Shim_T(IGate_T g) : base(g)
            {
                this.Gate = g;
            }

            public override Func<Qubit, QVoid> __Body__ => Gate.T_Body();

            public override Func<(IQArray<Qubit>, Qubit), QVoid> __ControlledBody__ => Gate.T_ControlledBody();

            public override Func<Qubit, QVoid> __AdjointBody__ => Gate.T_AdjointBody();

            public override Func<(IQArray<Qubit>, Qubit), QVoid> __ControlledAdjointBody__ => Gate.T_ControlledAdjointBody();
        }
    }
}

// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Intrinsic.Interfaces;

namespace Microsoft.Quantum.Intrinsic
{

    public partial class TargetIntrinsics
    {
        public class Shim_Rz : Rz
        {
            private IGate_Rz Gate { get; }

            public Shim_Rz(IGate_Rz g) : base(g)
            {
                this.Gate = g;
            }

            public override Func<(double, Qubit), QVoid> __Body__ => Gate.Rz_Body();

            public override Func<(double, Qubit), QVoid> __AdjointBody__ => Gate.Rz_AdjointBody();

            public override Func<(IQArray<Qubit>, (double, Qubit)), QVoid> __ControlledBody__ => Gate.Rz_ControlledBody();

            public override Func<(IQArray<Qubit>, (double, Qubit)), QVoid> __ControlledAdjointBody__ => Gate.Rz_ControlledAdjointBody();
        }
    }
}

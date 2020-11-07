// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Intrinsic.Interfaces;

namespace Microsoft.Quantum.Intrinsic
{

    public partial class TargetIntrinsics
    {
        public class Shim_Ry : Ry
        {
            private IGate_Ry Gate { get; }

            public Shim_Ry(IGate_Ry g) : base(g)
            {
                this.Gate = g;
            }

            public override Func<(double, Qubit), QVoid> __Body__ => Gate.Ry_Body();

            public override Func<(double, Qubit), QVoid> __AdjointBody__ => Gate.Ry_AdjointBody();

            public override Func<(IQArray<Qubit>, (double, Qubit)), QVoid> __ControlledBody__ => Gate.Ry_ControlledBody();

            public override Func<(IQArray<Qubit>, (double, Qubit)), QVoid> __ControlledAdjointBody__ => Gate.Ry_ControlledAdjointBody();
        }
    }
}

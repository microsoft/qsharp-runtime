// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Intrinsic.Interfaces;

namespace Microsoft.Quantum.Intrinsic
{

    public partial class TargetIntrinsics
    {
        internal class Shim_IsingYY : IsingYY
        {
            private IGate_IsingYY Gate { get; }

            public Shim_IsingYY(IGate_IsingYY g) : base(g)
            {
                this.Gate = g;
            }

            public override Func<(double, Qubit, Qubit), QVoid> __Body__ => Gate.IsingYY_Body();

            public override Func<(double, Qubit, Qubit), QVoid> __AdjointBody__ => Gate.IsingYY_AdjointBody();

            public override Func<(IQArray<Qubit>, (double, Qubit, Qubit)), QVoid> __ControlledBody__ => Gate.IsingYY_ControlledBody();

            public override Func<(IQArray<Qubit>, (double, Qubit, Qubit)), QVoid> __ControlledAdjointBody__ => Gate.IsingYY_ControlledAdjointBody();
        }
    }
}

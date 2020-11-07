// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Intrinsic.Interfaces;

namespace Microsoft.Quantum.Intrinsic
{

    public partial class TargetIntrinsics
    {
        internal class Shim_IsingZZ : IsingZZ
        {
            private IGate_IsingZZ Gate { get; }

            public Shim_IsingZZ(IGate_IsingZZ g) : base(g)
            {
                this.Gate = g;
            }

            public override Func<(double, Qubit, Qubit), QVoid> __Body__ => Gate.IsingZZ_Body();

            public override Func<(double, Qubit, Qubit), QVoid> __AdjointBody__ => Gate.IsingZZ_AdjointBody();

            public override Func<(IQArray<Qubit>, (double, Qubit, Qubit)), QVoid> __ControlledBody__ => Gate.IsingZZ_ControlledBody();

            public override Func<(IQArray<Qubit>, (double, Qubit, Qubit)), QVoid> __ControlledAdjointBody__ => Gate.IsingZZ_ControlledAdjointBody();
        }
    }
}

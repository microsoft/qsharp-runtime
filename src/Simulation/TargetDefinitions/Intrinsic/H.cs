// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Intrinsic.Interfaces;

namespace Microsoft.Quantum.Intrinsic
{
    public partial class TargetIntrinsics
    {
        public class Shim_H : H
        {
            private IGate_H Gate { get; }

            public Shim_H(IGate_H g) : base(g)
            {
                this.Gate = g;
            }

            public override Func<Qubit, QVoid> __Body__ => Gate.H_Body();

            public override Func<(IQArray<Qubit>, Qubit), QVoid> __ControlledBody__ => Gate.H_ControlledBody();
        }
    }
}

// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Intrinsic.Interfaces;

namespace Microsoft.Quantum.Intrinsic
{

    public partial class TargetIntrinsics
    {
        public class Shim_R : R
        {
            private IGate_R Gate { get; }

            public Shim_R(IGate_R g) : base(g)
            {
                this.Gate = g;
            }

            public override Func<(Pauli, double, Qubit), QVoid> __Body__ => Gate.R_Body();

            public override Func<(Pauli, double, Qubit), QVoid> __AdjointBody__ => Gate.R_AdjointBody();

            public override Func<(IQArray<Qubit>, (Pauli, double, Qubit)), QVoid> __ControlledBody__ => Gate.R_ControlledBody();

            public override Func<(IQArray<Qubit>, (Pauli, double, Qubit)), QVoid> __ControlledAdjointBody__ => Gate.R_ControlledAdjointBody();
        }
    }
}

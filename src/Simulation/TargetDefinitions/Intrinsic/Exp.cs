// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Intrinsic.Interfaces;

namespace Microsoft.Quantum.Intrinsic
{
    public partial class TargetIntrinsics
    {
        public class Shim_Exp : Quantum.Intrinsic.Exp
        {
            private IGate_Exp Gate { get; }


            public Shim_Exp(IGate_Exp g) : base(g)
            {
                this.Gate = g;
            }

            public override Func<(IQArray<Pauli>, double, IQArray<Qubit>), QVoid> __Body__ => Gate.Exp_Body();

            public override Func<(IQArray<Pauli>, double, IQArray<Qubit>), QVoid> __AdjointBody__ => Gate.Exp_AdjointBody();

            public override Func<(IQArray<Qubit>, (IQArray<Pauli>, double, IQArray<Qubit>)), QVoid> __ControlledBody__ => Gate.Exp_ControlledBody();
            public override Func<(IQArray<Qubit>, (IQArray<Pauli>, double, IQArray<Qubit>)), QVoid> __ControlledAdjointBody__ => Gate.Exp_ControlledAdjointBody();
        }
    }
}

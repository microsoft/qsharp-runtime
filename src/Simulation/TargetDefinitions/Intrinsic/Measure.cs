// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Intrinsic.Interfaces;

namespace Microsoft.Quantum.Intrinsic
{
    public partial class TargetIntrinsics
    {
        public class Shim_Measure : Measure
        {
            private IGate_Measure Gate { get; }

            public Shim_Measure(IGate_Measure g) : base(g)
            {
                this.Gate = g;
            }

            public override Func<(IQArray<Pauli>, IQArray<Qubit>), Result> __Body__ => Gate.Measure_Body();
        }
    }
}

// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Simulation.QuantumExecutor
{
    public partial class QuantumExecutorSimulator
    {
        public class QuantumExecutorSimM : Quantum.Intrinsic.M
        {
            private QuantumExecutorSimulator Simulator { get; }

            public QuantumExecutorSimM(QuantumExecutorSimulator m) : base(m)
            {
                this.Simulator = m;
            }

            public override Func<Qubit, Result> Body => (q) =>
            {
                return Simulator.QuantumExecutor.M(q);
            };
        }
    }
}

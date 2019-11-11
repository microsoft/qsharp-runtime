// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Simulation.QuantumExecutor
{
    public partial class QuantumExecutorSimulator
    {
        public class QuantumExecutorSimReset : Quantum.Intrinsic.Reset
        {
            private QuantumExecutorSimulator Simulator { get; }


            public QuantumExecutorSimReset(QuantumExecutorSimulator m) : base(m)
            {
                this.Simulator = m;
            }

            public override Func<Qubit, QVoid> Body => (q1) =>
            {

                Simulator.QuantumExecutor.Reset(q1);
                return QVoid.Instance;
            };
        }
    }
}

// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Simulation.QuantumProcessor
{
    public partial class QuantumProcessorDispatcher
    {
        public class QuantumProcessorDispatcherReset : Quantum.Intrinsic.Reset
        {
            private QuantumProcessorDispatcher Simulator { get; }

            public QuantumProcessorDispatcherReset(QuantumProcessorDispatcher m) : base(m)
            {
                this.Simulator = m;
            }

            public override Func<Qubit, QVoid> Body => (q1) =>
            {
                Simulator.QuantumProcessor.Reset(q1);
                return QVoid.Instance;
            };
        }
    }
}

// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Simulation.QuantumProcessor
{
    public partial class QuantumProcessorDispatcher
    {
        public class QuantumProcessorDispatcherM : Quantum.Intrinsic.M
        {
            private QuantumProcessorDispatcher Simulator { get; }

            public QuantumProcessorDispatcherM(QuantumProcessorDispatcher m) : base(m)
            {
                this.Simulator = m;
            }

            public override Func<Qubit, Result> Body => (q) =>
            {
                return Simulator.QuantumProcessor.M(q);
            };
        }
    }
}

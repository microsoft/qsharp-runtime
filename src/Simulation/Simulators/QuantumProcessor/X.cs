// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Simulation.QuantumProcessor
{
    public partial class QuantumProcessorDispatcher
    {
        public class QuantumProcessorDispatcherX : Quantum.Intrinsic.X
        {
            private QuantumProcessorDispatcher Simulator { get; }

            public QuantumProcessorDispatcherX(QuantumProcessorDispatcher m) : base(m)
            {
                this.Simulator = m;
            }

            public override Func<Qubit, QVoid> Body => (q1) =>
            {
                Simulator.QuantumProcessor.X(q1);
                return QVoid.Instance;
            };

            public override Func<(IQArray<Qubit>, Qubit), QVoid> ControlledBody => (args) =>
            {
                var (ctrls, q1) = args;
                Simulator.QuantumProcessor.ControlledX(ctrls, q1);
                return QVoid.Instance;
            };
        }
    }
}

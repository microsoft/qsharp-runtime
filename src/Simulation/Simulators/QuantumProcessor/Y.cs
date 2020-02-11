// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Simulation.QuantumProcessor
{
    public partial class QuantumProcessorDispatcher
    {
        public class QuantumProcessorDispatcherY : Quantum.Intrinsic.Y
        {
            private QuantumProcessorDispatcher Simulator { get; }

            public QuantumProcessorDispatcherY(QuantumProcessorDispatcher m) : base(m)
            {
                this.Simulator = m;
            }

            public override Func<Qubit, QVoid> Body => (q1) =>
            {
                Simulator.QuantumProcessor.Y(q1);
                return QVoid.Instance;
            };

            public override Func<(IQArray<Qubit>, Qubit), QVoid> ControlledBody => (_args) =>
            {
                (IQArray<Qubit> ctrls, Qubit q1) = _args;

                if ((ctrls == null) || (ctrls.Count == 0))
                {
                    Simulator.QuantumProcessor.Y(q1);
                }
                else
                {
                    Simulator.QuantumProcessor.ControlledY(ctrls, q1);
                }

                return QVoid.Instance;
            };            
        }
    }
}

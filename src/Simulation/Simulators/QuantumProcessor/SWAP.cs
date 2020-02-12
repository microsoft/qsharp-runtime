// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Simulation.QuantumProcessor
{
    public partial class QuantumProcessorDispatcher
    {
        public class QuantumProcessorDispatcherSWAP : Quantum.Intrinsic.SWAP
        {
            private QuantumProcessorDispatcher Simulator { get; }

            public QuantumProcessorDispatcherSWAP(QuantumProcessorDispatcher m) : base(m)
            {
                this.Simulator = m;
            }

            public override Func<(Qubit,Qubit), QVoid> Body => (q1) =>
            {
                Simulator.QuantumProcessor.SWAP(q1.Item1, q1.Item2);
                return QVoid.Instance;
            };

            public override Func<(IQArray<Qubit>, (Qubit, Qubit)), QVoid> ControlledBody => (args) =>
            {
                (IQArray<Qubit> ctrls, (Qubit q1, Qubit q2) ) = args;

                if ((ctrls == null) || (ctrls.Count == 0))
                {
                    Simulator.QuantumProcessor.SWAP(q1, q2);
                }
                else
                {
                    Simulator.QuantumProcessor.ControlledSWAP(ctrls, q1, q2);
                }

                return QVoid.Instance;
            };
        }
    }
}

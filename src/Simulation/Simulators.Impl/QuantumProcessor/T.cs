// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Simulation.QuantumProcessor
{
    public partial class QuantumProcessorDispatcher
    {
        public class QuantumProcessorDispatcherT : Quantum.Intrinsic.T
        {
            private QuantumProcessorDispatcher Simulator { get; }

            public QuantumProcessorDispatcherT(QuantumProcessorDispatcher m) : base(m)
            {
                this.Simulator = m;
            }

            public override Func<Qubit, QVoid> __Body__ => (q1) =>
            {
                Simulator.QuantumProcessor.T(q1);
                return QVoid.Instance;
            };

            public override Func<(IQArray<Qubit>, Qubit), QVoid> __ControlledBody__ => (_args) =>
            {
                (IQArray<Qubit> ctrls, Qubit q1) = _args;

                Simulator.QuantumProcessor.ControlledT(ctrls, q1);

                return QVoid.Instance;
            };

            public override Func<Qubit, QVoid> __AdjointBody__ => (q1) =>
            {
                Simulator.QuantumProcessor.TAdjoint(q1);
                return QVoid.Instance;
            };

            public override Func<(IQArray<Qubit>, Qubit), QVoid> __ControlledAdjointBody__ => (_args) =>
            {
                (IQArray<Qubit> ctrls, Qubit q1) = _args;

                if ((ctrls == null) || (ctrls.Count == 0))
                {
                    Simulator.QuantumProcessor.TAdjoint(q1);
                }
                else
                {
                    Simulator.QuantumProcessor.ControlledTAdjoint(ctrls, q1);
                }

                return QVoid.Instance;
            };
        }
    }
}

// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using Microsoft.Quantum.Simulation.Common;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Simulation.QuantumProcessor
{

    public partial class QuantumProcessorDispatcher
    {
        public class QuantumProcessorDispatcherR1Frac : Quantum.Intrinsic.R1Frac
        {
            private QuantumProcessorDispatcher Simulator { get; }

            public QuantumProcessorDispatcherR1Frac(QuantumProcessorDispatcher m) : base(m)
            {
                this.Simulator = m;
            }

            public override Func<(long, long, Qubit), QVoid> __Body__ => (_args) =>
            {
                (long num, long denom, Qubit q1) = _args;
                (long numNew, long denomNew) = CommonUtils.Reduce(num, denom);
                Simulator.QuantumProcessor.R1Frac(numNew, denomNew, q1);
                return QVoid.Instance;
            };

            public override Func<(long, long, Qubit), QVoid> __AdjointBody__ => (_args) =>
            {
                (long num, long denom, Qubit q1) = _args;
                return this.__Body__.Invoke((-num, denom, q1));
            };

            public override Func<(IQArray<Qubit>, (long, long, Qubit)), QVoid> __ControlledBody__ => (_args) =>
            {
                (IQArray<Qubit> ctrls, (long num, long denom, Qubit q1)) = _args;
                (long numNew, long denomNew) = CommonUtils.Reduce(num, denom);

                if ((ctrls == null) || (ctrls.Count == 0))
                {
                    Simulator.QuantumProcessor.R1Frac(numNew, denomNew, q1);
                }
                else
                {
                    Simulator.QuantumProcessor.ControlledR1Frac(ctrls, numNew, denomNew, q1);
                }

                return QVoid.Instance;
            };

            public override Func<(IQArray<Qubit>, (long, long, Qubit)), QVoid> __ControlledAdjointBody__ => (_args) =>
            {
                (IQArray<Qubit> ctrls, (long num, long denom, Qubit q1)) = _args;
                return this.__ControlledBody__.Invoke((ctrls, (-num, denom, q1)));
            };
        }
    }
}

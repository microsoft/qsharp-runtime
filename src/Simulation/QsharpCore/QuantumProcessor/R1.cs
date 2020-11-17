// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Simulation.QuantumProcessor
{

    public partial class QuantumProcessorDispatcher
    {
        public class QuantumProcessorDispatcherR1 : Quantum.Intrinsic.R1
        {
            private QuantumProcessorDispatcher Simulator { get; }

            public QuantumProcessorDispatcherR1(QuantumProcessorDispatcher m) : base(m)
            {
                this.Simulator = m;
            }

            public override Func<(double, Qubit), QVoid> __Body__ => (_args) =>
            {
                (double angle, Qubit q1) = _args;
                Simulator.QuantumProcessor.R1(angle, q1);
                return QVoid.Instance;
            };

            public override Func<(double, Qubit), QVoid> __AdjointBody__ => (_args) =>
            {
                (double angle, Qubit q1) = _args;
                return this.__Body__.Invoke((-angle, q1));
            };

            public override Func<(IQArray<Qubit>, ( double, Qubit)), QVoid> __ControlledBody__ => (_args) =>
            {
                (IQArray<Qubit> ctrls, (double angle, Qubit q1)) = _args;

                if ((ctrls == null) || (ctrls.Count == 0))
                {
                    Simulator.QuantumProcessor.R1(angle, q1);
                }
                else
                {
                    Simulator.QuantumProcessor.ControlledR1(ctrls, angle, q1);
                }

                return QVoid.Instance;
            };


            public override Func<(IQArray<Qubit>, (double, Qubit)), QVoid> __ControlledAdjointBody__ => (_args) =>
            {
                (IQArray<Qubit> ctrls, (double angle, Qubit q1)) = _args;
                return this.__ControlledBody__.Invoke((ctrls, (-angle, q1)));
            };
        }
    }
}

// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using Microsoft.Quantum.Simulation.Common;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Simulation.QuantumProcessor
{

    public partial class QuantumProcessorDispatcher
    {
        public class QuantumProcessorDispatcherRFrac : Quantum.Intrinsic.RFrac
        {

            private QuantumProcessorDispatcher Simulator { get; }

            public QuantumProcessorDispatcherRFrac(QuantumProcessorDispatcher m) : base(m)
            {
                this.Simulator = m;
            }

            public override Func<(Pauli, long, long, Qubit), QVoid> Body => (_args) =>
            {
                (Pauli basis, long num, long denom, Qubit q1) = _args;
                if (basis != Pauli.PauliI)
                {
                    (long numNew, long denomNew) = CommonUtils.Reduce(num, denom);
                    Simulator.QuantumProcessor.RFrac(basis, numNew, denomNew, q1);
                }
                return QVoid.Instance;
            };

            public override Func<(Pauli, long, long, Qubit), QVoid> AdjointBody => (_args) =>
            {
                (Pauli basis, long num, long denom, Qubit q1) = _args;
                return this.Body.Invoke((basis, -num, denom, q1));
            };

            public override Func<(IQArray<Qubit>, (Pauli, long, long, Qubit)), QVoid> ControlledBody => (_args) =>
            {
                (IQArray<Qubit> ctrls, (Pauli basis, long num, long denom, Qubit q1)) = _args;
                (long numNew, long denomNew) = CommonUtils.Reduce(num, denom);

                if ((ctrls == null) || (ctrls.Count == 0))
                {
                    Simulator.QuantumProcessor.RFrac(basis, numNew, denomNew, q1);
                }
                else
                {
                    Simulator.QuantumProcessor.ControlledRFrac(ctrls, basis, numNew, denomNew, q1);
                }

                return QVoid.Instance;
            };

            public override Func<(IQArray<Qubit>, (Pauli, long, long, Qubit)), QVoid> ControlledAdjointBody => (_args) =>
            {
                (IQArray<Qubit> ctrls, (Pauli basis, long num, long denom, Qubit q1)) = _args;
                return this.ControlledBody.Invoke((ctrls, (basis, -num, denom, q1)));
            };
        }
    }
}

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
                var (basis, num, denom , q1) = _args;
                if (basis != Pauli.PauliI)
                {
                    var (numNew, denomNew) = CommonUtils.Reduce(num, denom);
                    Simulator.QuantumProcessor.RFrac(basis, numNew, denomNew, q1);
                }
                return QVoid.Instance;
            };

            public override Func<(Pauli, long, long, Qubit), QVoid> AdjointBody => (_args) =>
            {
                var (basis, num, denom, q1) = _args;
                return this.Body.Invoke((basis, -num, denom, q1));
            };

            public override Func<(IQArray<Qubit>, (Pauli, long, long, Qubit)), QVoid> ControlledBody => (_args) =>
            {
                var (ctrls, (basis, num, denom, q1)) = _args;
                var (numNew, denomNew) = CommonUtils.Reduce(num, denom);
                Simulator.QuantumProcessor.ControlledRFrac(ctrls, basis, numNew, denomNew, q1);
                return QVoid.Instance;
            };

            public override Func<(IQArray<Qubit>, (Pauli, long, long, Qubit)), QVoid> ControlledAdjointBody => (_args) =>
            {
                var (ctrls, (basis, num, denom, q1)) = _args;
                return this.ControlledBody.Invoke((ctrls, (basis, -num, denom, q1)));
            };
        }
    }
}

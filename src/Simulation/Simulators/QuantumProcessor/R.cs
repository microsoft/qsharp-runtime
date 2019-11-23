// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Simulation.QuantumProcessor
{

    public partial class QuantumProcessorDispatcher
    {
        public class QuantumProcessorDispatcherR : Quantum.Intrinsic.R
        {
            private QuantumProcessorDispatcher Simulator { get; }


            public QuantumProcessorDispatcherR(QuantumProcessorDispatcher m) : base(m)
            {
                this.Simulator = m;
            }

            public override Func<(Pauli, double, Qubit), QVoid> Body => (_args) =>
            {
                var (basis, angle, q1) = _args;
                if (basis != Pauli.PauliI)
                {
                    Simulator.QuantumProcessor.R(basis, angle,q1);
                }
                return QVoid.Instance;
            };

            public override Func<(Pauli, double, Qubit), QVoid> AdjointBody => (_args) =>
            {
                var (basis, angle, q1) = _args;
                return this.Body.Invoke((basis, -angle, q1));
            };

            public override Func<(IQArray<Qubit>, (Pauli, double, Qubit)), QVoid> ControlledBody => (_args) =>
            {
                var (ctrls, (basis, angle, q1)) = _args;
                Simulator.QuantumProcessor.ControlledR(ctrls, basis, angle, q1);
                return QVoid.Instance;
            };


            public override Func<(IQArray<Qubit>, (Pauli, double, Qubit)), QVoid> ControlledAdjointBody => (_args) =>
            {
                var (ctrls, (basis, angle, q1)) = _args;
                return this.ControlledBody.Invoke((ctrls, (basis, -angle, q1)));
            };
        }
    }
}

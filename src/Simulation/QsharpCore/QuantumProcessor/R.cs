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

            public override Func<(Pauli, double, Qubit), QVoid> __Body__ => (_args) =>
            {
                (Pauli basis, double angle, Qubit q1) = _args;
                if (basis != Pauli.PauliI)
                {
                    Simulator.QuantumProcessor.R(basis, angle,q1);
                }
                return QVoid.Instance;
            };

            public override Func<(Pauli, double, Qubit), QVoid> __AdjointBody__ => (_args) =>
            {
                (Pauli basis, double angle, Qubit q1) = _args;
                return this.__Body__.Invoke((basis, -angle, q1));
            };

            public override Func<(IQArray<Qubit>, (Pauli, double, Qubit)), QVoid> __ControlledBody__ => (_args) =>
            {
                (IQArray<Qubit> ctrls, (Pauli basis, double angle, Qubit q1)) = _args;

                if ((ctrls == null) || (ctrls.Count == 0))
                {
                    Simulator.QuantumProcessor.R(basis, angle, q1);
                }
                else
                {
                    Simulator.QuantumProcessor.ControlledR(ctrls, basis, angle, q1);
                }

                return QVoid.Instance;
            };


            public override Func<(IQArray<Qubit>, (Pauli, double, Qubit)), QVoid> __ControlledAdjointBody__ => (_args) =>
            {
                (IQArray<Qubit> ctrls, (Pauli basis, double angle, Qubit q1)) = _args;
                return this.__ControlledBody__.Invoke((ctrls, (basis, -angle, q1)));
            };
        }
    }
}

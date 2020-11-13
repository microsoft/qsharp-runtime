// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Simulation.QuantumProcessor
{
    public partial class QuantumProcessorDispatcher
    {
        public Func<Qubit, QVoid> S_Body() => (q1) =>
        {
            this.QuantumProcessor.S(q1);
            return QVoid.Instance;
        };

        public Func<(IQArray<Qubit>, Qubit), QVoid> S_ControlledBody() => (_args) =>
        {
            (IQArray<Qubit> ctrls, Qubit q1) = _args;

            if ((ctrls == null) || (ctrls.Count == 0))
            {
                this.QuantumProcessor.S(q1);
            }
            else
            {
                this.QuantumProcessor.ControlledS(ctrls, q1);
            }

            return QVoid.Instance;
        };

        public Func<Qubit, QVoid> S_AdjointBody() => (q1) =>
        {
            this.QuantumProcessor.SAdjoint(q1);
            return QVoid.Instance;
        };

        public Func<(IQArray<Qubit>, Qubit), QVoid> S_ControlledAdjointBody() => (_args) =>
        {
            (IQArray<Qubit> ctrls, Qubit q1) = _args;

            if ((ctrls == null) || (ctrls.Count == 0))
            {
                this.QuantumProcessor.SAdjoint(q1);
            }
            else
            {
                this.QuantumProcessor.ControlledSAdjoint(ctrls, q1);
            }

            return QVoid.Instance;
        };
    }
}

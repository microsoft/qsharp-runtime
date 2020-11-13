// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Simulation.QuantumProcessor
{
    public partial class QuantumProcessorDispatcher
    {
        public Func<Qubit, QVoid> T_Body() => (q1) =>
        {
            this.QuantumProcessor.T(q1);
            return QVoid.Instance;
        };

        public Func<(IQArray<Qubit>, Qubit), QVoid> T_ControlledBody() => (_args) =>
        {
            (IQArray<Qubit> ctrls, Qubit q1) = _args;

            this.QuantumProcessor.ControlledT(ctrls, q1);

            return QVoid.Instance;
        };

        public Func<Qubit, QVoid> T_AdjointBody() => (q1) =>
        {
            this.QuantumProcessor.TAdjoint(q1);
            return QVoid.Instance;
        };

        public Func<(IQArray<Qubit>, Qubit), QVoid> T_ControlledAdjointBody() => (_args) =>
        {
            (IQArray<Qubit> ctrls, Qubit q1) = _args;

            if ((ctrls == null) || (ctrls.Count == 0))
            {
                this.QuantumProcessor.TAdjoint(q1);
            }
            else
            {
                this.QuantumProcessor.ControlledTAdjoint(ctrls, q1);
            }

            return QVoid.Instance;
        };
    }
}

// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Simulation.QuantumProcessor
{
    public partial class QuantumProcessorDispatcher
    {
        public Func<Qubit, QVoid> Y_Body() => (q1) =>
        {
            this.QuantumProcessor.Y(q1);
            return QVoid.Instance;
        };

        public Func<(IQArray<Qubit>, Qubit), QVoid> Y_ControlledBody() => (_args) =>
        {
            (IQArray<Qubit> ctrls, Qubit q1) = _args;

            if ((ctrls == null) || (ctrls.Count == 0))
            {
                this.QuantumProcessor.Y(q1);
            }
            else
            {
                this.QuantumProcessor.ControlledY(ctrls, q1);
            }

            return QVoid.Instance;
        };
    }
}

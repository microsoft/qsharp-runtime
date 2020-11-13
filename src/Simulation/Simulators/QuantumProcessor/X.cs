// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Simulation.QuantumProcessor
{
    public partial class QuantumProcessorDispatcher
    {
        public Func<Qubit, QVoid> X_Body() => (q1) =>
        {
            this.QuantumProcessor.X(q1);
            return QVoid.Instance;
        };

        public Func<(IQArray<Qubit>, Qubit), QVoid> X_ControlledBody() => (args) =>
        {
            (IQArray<Qubit> ctrls, Qubit q1) = args;

            if ((ctrls == null) || (ctrls.Count == 0))
            {
                this.QuantumProcessor.X(q1);
            }
            else
            {
                this.QuantumProcessor.ControlledX(ctrls, q1);
            }

            return QVoid.Instance;
        };
    }
}

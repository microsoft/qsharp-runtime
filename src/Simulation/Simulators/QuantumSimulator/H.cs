// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.Runtime.InteropServices;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Simulation.Simulators
{
    public partial class QuantumSimulator
    {
        public virtual Func<Qubit, QVoid> H_Body() => (q1) =>
        {
            this.CheckQubit(q1);

            H(this.Id, (uint)q1.Id);

            return QVoid.Instance;
        };

        public virtual Func<(IQArray<Qubit>, Qubit), QVoid> H_ControlledBody() => (args) =>
        {
            var (ctrls, q1) = args;

            this.CheckQubits(ctrls, q1);

            SafeControlled(ctrls,
                () => H_Body().Invoke(q1),
                (count, ids) => MCH(this.Id, count, ids, (uint)q1.Id));

            return QVoid.Instance;
        };
    }
}

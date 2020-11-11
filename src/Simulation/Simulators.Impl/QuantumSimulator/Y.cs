// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.Runtime.InteropServices;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Simulation.Simulators
{
    public partial class QuantumSimulator
    {
        public Func<Qubit, QVoid> Y_Body() => (q1) =>
        {
            this.CheckQubit(q1);

            Y(this.Id, (uint)q1.Id);

            return QVoid.Instance;
        };

        public Func<(IQArray<Qubit>, Qubit), QVoid> Y_ControlledBody() => (_args) =>
        {
            (IQArray<Qubit> ctrls, Qubit q1) = _args;

            this.CheckQubits(ctrls, q1);

            SafeControlled(ctrls,
                () => Y_Body().Invoke(q1),
                (count, ids) => MCY(this.Id, count, ids, (uint)q1.Id));

            return QVoid.Instance;
        };
    }
}

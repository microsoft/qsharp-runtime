// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.Runtime.InteropServices;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Simulation.Simulators
{
    public partial class QuantumSimulator
    {
        public virtual Func<Qubit, QVoid> S_Body() => (q1) =>
        {
            this.CheckQubit(q1);

            S(this.Id, (uint)q1.Id);

            return QVoid.Instance;
        };

        public virtual Func<(IQArray<Qubit>, Qubit), QVoid> S_ControlledBody() => (_args) =>
        {
            (IQArray<Qubit> ctrls, Qubit q1) = _args;

            this.CheckQubits(ctrls, q1);

            SafeControlled(ctrls,
                () => S_Body().Invoke(q1),
                (count, ids) => MCS(this.Id, count, ids, (uint)q1.Id));

            return QVoid.Instance;
        };

        public virtual Func<Qubit, QVoid> S_AdjointBody() => (q1) =>
        {
            this.CheckQubit(q1);

            AdjS(this.Id, (uint)q1.Id);

            return QVoid.Instance;
        };

        public virtual Func<(IQArray<Qubit>, Qubit), QVoid> S_ControlledAdjointBody() => (_args) =>
        {
            (IQArray<Qubit> ctrls, Qubit q1) = _args;

            this.CheckQubits(ctrls, q1);

            SafeControlled(ctrls,
                () => S_AdjointBody().Invoke(q1),
                (count, ids) => MCAdjS(this.Id, count, ids, (uint)q1.Id));

            return QVoid.Instance;
        };
    }
}

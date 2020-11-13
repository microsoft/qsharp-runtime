// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.Runtime.InteropServices;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Simulation.Simulators
{
    public partial class QuantumSimulator
    {
        public Func<Qubit, QVoid> T_Body() => (q1) =>
        {
            this.CheckQubit(q1);

            T(this.Id, (uint)q1.Id);
            return QVoid.Instance;
        };

        public Func<(IQArray<Qubit>, Qubit), QVoid> T_ControlledBody() => (_args) =>
        {
            (IQArray<Qubit> ctrls, Qubit q1) = _args;

            this.CheckQubits(ctrls, q1);

            SafeControlled(ctrls,
                () => T_Body().Invoke(q1),
                (count, ids) => MCT(this.Id, count, ids, (uint)q1.Id));

            return QVoid.Instance;
        };

        public Func<Qubit, QVoid> T_AdjointBody() => (q1) =>
        {
            this.CheckQubit(q1);
            
            AdjT(this.Id, (uint)q1.Id);
            return QVoid.Instance;
        };

        public Func<(IQArray<Qubit>, Qubit), QVoid> T_ControlledAdjointBody() => (_args) =>
        {
            (IQArray<Qubit> ctrls, Qubit q1) = _args;

            this.CheckQubits(ctrls, q1);

            SafeControlled(ctrls,
                () => T_AdjointBody().Invoke(q1),
                (count, ids) => MCAdjT(this.Id, count, ids, (uint)q1.Id));

            return QVoid.Instance;
        };
    }
}

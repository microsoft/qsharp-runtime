// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.Runtime.InteropServices;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Simulation.Simulators
{

    public partial class QuantumSimulator
    {
        public virtual Func<(double, Qubit), QVoid> Rz_Body() => (args) =>
        {
            var (angle, target) = args;
            this.CheckQubit(target, nameof(target));
            CheckAngle(angle);
            R(this.Id, Pauli.PauliZ, angle, (uint)target.Id);
            return QVoid.Instance;
        };

        public virtual Func<(double, Qubit), QVoid> Rz_AdjointBody() => (_args) =>
        {
            var (angle, q1) = _args;

            return Rz_Body().Invoke((-angle, q1));
        };

        public virtual Func<(IQArray<Qubit>, (double, Qubit)), QVoid> Rz_ControlledBody() => (args) =>
        {
            var (ctrls, (angle, target)) = args;
            this.CheckQubits(ctrls, target);
            CheckAngle(angle);
            MCR(this.Id, Pauli.PauliZ, angle, (uint)ctrls.Length, ctrls.GetIds(), (uint)target.Id);
            return QVoid.Instance;
        };

        public virtual Func<(IQArray<Qubit>, (double, Qubit)), QVoid> Rz_ControlledAdjointBody() => (_args) =>
        {
            var (ctrls, (angle, q1)) = _args;

            return Rz_ControlledBody().Invoke((ctrls, (-angle, q1)));
        };
    }
}

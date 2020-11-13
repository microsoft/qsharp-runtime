// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.Runtime.InteropServices;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Simulation.Simulators
{

    public partial class QuantumSimulator
    {
        public Func<(double, Qubit), QVoid> Rx_Body() => (args) =>
        {
            var (angle, target) = args;
            this.CheckQubit(target, nameof(target));
            CheckAngle(angle);
            R(this.Id, Pauli.PauliX, angle, (uint)target.Id);
            return QVoid.Instance;
        };

        public Func<(double, Qubit), QVoid> Rx_AdjointBody() => (_args) =>
        {
            var (angle, q1) = _args;

            return Rx_Body().Invoke((-angle, q1));
        };

        public Func<(IQArray<Qubit>, (double, Qubit)), QVoid> Rx_ControlledBody() => (args) =>
        {
            var (ctrls, (angle, target)) = args;
            this.CheckQubits(ctrls, target);
            CheckAngle(angle);
            MCR(this.Id, Pauli.PauliX, angle, (uint)ctrls.Length, ctrls.GetIds(), (uint)target.Id);
            return QVoid.Instance;
        };

        public Func<(IQArray<Qubit>, (double, Qubit)), QVoid> Rx_ControlledAdjointBody() => (_args) =>
        {
            var (ctrls, (angle, q1)) = _args;

            return Rx_ControlledBody().Invoke((ctrls, (-angle, q1)));
        };
    }
}

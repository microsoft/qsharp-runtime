// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.Runtime.InteropServices;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Simulation.Simulators
{

    public partial class QuantumSimulator
    {
        public virtual Func<(Pauli, double, Qubit), QVoid> R_Body() => (_args) =>
        {
            var (basis, angle, q1) = _args;

            this.CheckQubit(q1);
            CheckAngle(angle);

            R(this.Id, basis, angle, (uint)q1.Id);

            return QVoid.Instance;
        };

        public virtual Func<(Pauli, double, Qubit), QVoid> R_AdjointBody() => (_args) =>
        {
            var (basis, angle, q1) = _args;

            return R_Body().Invoke((basis, -angle, q1));
        };

        public virtual Func<(IQArray<Qubit>, (Pauli, double, Qubit)), QVoid> R_ControlledBody() => (_args) =>
        {
            var (ctrls, (basis, angle, q1)) = _args;

            this.CheckQubits(ctrls, q1);
            CheckAngle(angle);

            SafeControlled(ctrls,
                () => R_Body().Invoke((basis, angle, q1)),
                (count, ids) => MCR(this.Id, basis, angle, count, ids, (uint)q1.Id));

            return QVoid.Instance;
        };


        public virtual Func<(IQArray<Qubit>, (Pauli, double, Qubit)), QVoid> R_ControlledAdjointBody() => (_args) =>
        {
            var (ctrls, (basis, angle, q1)) = _args;

            return R_ControlledBody().Invoke((ctrls, (basis, -angle, q1)));
        };
    }
}

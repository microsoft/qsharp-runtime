// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.Runtime.InteropServices;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Simulation.Simulators
{
    public partial class QuantumSimulator
    {
        public virtual Func<(double, Qubit), QVoid> ApplyUncontrolledRz_Body() => (args) =>
        {
            var (angle, target) = args;
            this.CheckQubit(target, nameof(target));
            CheckAngle(angle);
            R(this.Id, Pauli.PauliZ, angle, (uint)target.Id);
            return QVoid.Instance;
        };

        public virtual Func<(double, Qubit), QVoid> ApplyUncontrolledRz_AdjointBody() => (_args) =>
        {
            var (angle, q1) = _args;

            return ApplyUncontrolledRz_Body().Invoke((-angle, q1));
        };
    }
}

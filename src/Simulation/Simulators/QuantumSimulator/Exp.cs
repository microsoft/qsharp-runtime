// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.Linq;
using System.Runtime.InteropServices;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Simulation.Simulators
{
    public partial class QuantumSimulator
    {
        public virtual Func<(IQArray<Pauli>, double, IQArray<Qubit>), QVoid> Exp_Body() => (_args) =>
        {
            var (paulis, theta, qubits) = _args;

            this.CheckQubits(qubits);
            CheckAngle(theta);

            if (paulis.Length != qubits.Length)
            {
                throw new InvalidOperationException($"Both input arrays for Exp (paulis, qubits), must be of same size.");
            }

            Exp(this.Id, (uint)paulis.Length, paulis.ToArray(), theta, qubits.GetIds());

            return QVoid.Instance;
        };

        public virtual Func<(IQArray<Pauli>, double, IQArray<Qubit>), QVoid> Exp_AdjointBody() => (_args) =>
        {
            var (paulis, angle, qubits) = _args;

            return Exp_Body().Invoke((paulis, -angle, qubits));
        };

        public virtual Func<(IQArray<Qubit>, (IQArray<Pauli>, double, IQArray<Qubit>)), QVoid> Exp_ControlledBody() => (_args) =>
        {
            var (ctrls, (paulis, angle, qubits)) = _args;

            this.CheckQubits(ctrls, qubits);
            CheckAngle(angle);

            if (paulis.Length != qubits.Length)
            {
                throw new InvalidOperationException($"Both input arrays for Exp (paulis, qubits), must be of same size.");
            }

            SafeControlled(ctrls,
                () => Exp_Body().Invoke((paulis, angle, qubits)),
                (count, ids) => MCExp(this.Id, (uint)paulis.Length, paulis.ToArray(), angle, count, ids, qubits.GetIds()));

            return QVoid.Instance;
        };

        public virtual Func<(IQArray<Qubit>, (IQArray<Pauli>, double, IQArray<Qubit>)), QVoid> Exp_ControlledAdjointBody() => (_args) =>
        {
            var (ctrls, (paulis, angle, qubits)) = _args;

            return Exp_ControlledBody().Invoke((ctrls, (paulis, -angle, qubits)));
        };
    }
}

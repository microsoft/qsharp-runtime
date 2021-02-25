// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Simulation.Simulators
{
    public partial class QuantumSimulator
    {
        public virtual void Exp__Body(IQArray<Pauli> paulis, double angle, IQArray<Qubit> targets)
        {
            this.CheckQubits(targets);
            CheckAngle(angle);

            if (paulis.Length != targets.Length)
            {
                throw new InvalidOperationException($"Both input arrays for Exp (paulis, targets), must be of same size.");
            }

            Exp(this.Id, (uint)paulis.Length, paulis.ToArray(), angle, targets.GetIds());
        }

        public virtual void Exp__AdjointBody(IQArray<Pauli> paulis, double angle, IQArray<Qubit> targets)
        {
            Exp__Body(paulis, -angle, targets);
        }

        public virtual void Exp__ControlledBody(IQArray<Qubit> controls, IQArray<Pauli> paulis, double angle, IQArray<Qubit> targets)
        {
            this.CheckQubits(controls, targets);
            CheckAngle(angle);

            if (paulis.Length != targets.Length)
            {
                throw new InvalidOperationException($"Both input arrays for Exp (paulis, qubits), must be of same size.");
            }

            SafeControlled(controls,
                () => Exp__Body(paulis, angle, targets),
                (count, ids) => MCExp(this.Id, (uint)paulis.Length, paulis.ToArray(), angle, count, ids, targets.GetIds()));
        }

        public virtual void Exp__ControlledAdjointBody(IQArray<Qubit> controls, IQArray<Pauli> paulis, double angle, IQArray<Qubit> targets)
        {
            Exp__ControlledBody(controls, paulis, -angle, targets);
        }
    }
}

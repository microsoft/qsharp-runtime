// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Simulation.Simulators
{
    public partial class QuantumSimulator
    {
        public virtual void IsingZZ__Body(double angle, Qubit target1, Qubit target2)
        {
            var paulis = new Pauli[]{ Pauli.PauliZ, Pauli.PauliZ };
            var targets = new QArray<Qubit>(new Qubit[]{ target1, target2 });
            CheckAngle(angle);
            this.CheckQubits(targets);

            Exp(this.Id, (uint)targets.Length, paulis, angle * 2.0, targets.GetIds());
        }

        public virtual void IsingZZ__AdjointBody(double angle, Qubit target1, Qubit target2)
        {
            IsingZZ__Body(-angle, target1, target2);
        }

        public virtual void IsingZZ__ControlledBody(IQArray<Qubit> controls, double angle, Qubit target1, Qubit target2)
        {
            if (controls == null || controls.Length == 0)
            {
                IsingZZ__Body(angle, target1, target2);
            }
            else
            {
                var targets = new QArray<Qubit>(new Qubit[]{ target1, target2 });
                var paulis = new Pauli[]{ Pauli.PauliZ, Pauli.PauliZ };
                CheckAngle(angle);
                this.CheckQubits(QArray<Qubit>.Add(controls, targets));

                MCExp(this.Id, (uint)targets.Length, paulis, angle * 2.0, (uint)controls.Length, controls.GetIds(), targets.GetIds());
            }
        }

        public virtual void IsingZZ__ControlledAdjointBody(IQArray<Qubit> controls, double angle, Qubit target1, Qubit target2)
        {
            IsingZZ__ControlledBody(controls, -angle, target1, target2);
        }
    }
}

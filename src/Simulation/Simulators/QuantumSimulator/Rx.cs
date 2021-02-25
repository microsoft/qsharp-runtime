// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Simulation.Simulators
{
    public partial class QuantumSimulator
    {
        public virtual void Rx__Body(double angle, Qubit target)
        {
            this.CheckQubit(target, nameof(target));
            CheckAngle(angle);
            R(this.Id, Pauli.PauliX, angle, (uint)target.Id);
        }

        public virtual void Rx__AdjointBody(double angle, Qubit target)
        {
            Rx__Body(-angle, target);
        }

        public virtual void Rx__ControlledBody(IQArray<Qubit> controls, double angle, Qubit target)
        {
            this.CheckQubits(controls, target);
            CheckAngle(angle);
            MCR(this.Id, Pauli.PauliX, angle, (uint)controls.Length, controls.GetIds(), (uint)target.Id);
        }

        public virtual void Rx__ControlledAdjointBody(IQArray<Qubit> controls, double angle, Qubit target)
        {
            Rx__ControlledBody(controls, -angle, target);
        }
    }
}

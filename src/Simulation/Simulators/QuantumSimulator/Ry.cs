// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Simulation.Simulators
{
    public partial class QuantumSimulator
    {
        public virtual void Ry__Body(double angle, Qubit target)
        {
            this.CheckQubit(target, nameof(target));
            CheckAngle(angle);
            R(this.Id, Pauli.PauliY, angle, (uint)target.Id);
        }

        public virtual void Ry__AdjointBody(double angle, Qubit target)
        {
            Ry__Body(-angle, target);
        }

        public virtual void Ry__ControlledBody(IQArray<Qubit> controls, double angle, Qubit target)
        {
            this.CheckQubits(controls, target);
            CheckAngle(angle);
            MCR(this.Id, Pauli.PauliY, angle, (uint)controls.Length, controls.GetIds(), (uint)target.Id);
        }

        public virtual void Ry__ControlledAdjointBody(IQArray<Qubit> controls, double angle, Qubit target)
        {
            Ry__ControlledBody(controls, -angle, target);
        }
    }
}

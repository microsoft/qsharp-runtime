// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Simulation.Simulators
{
    public partial class QuantumSimulator
    {
        public virtual void ApplyUncontrolledRx__Body(double angle, Qubit target)
        {
            this.CheckQubit(target, nameof(target));
            CheckAngle(angle);
            R(this.Id, Pauli.PauliX, angle, (uint)target.Id);
        }

        public virtual void ApplyUncontrolledRx__AdjointBody(double angle, Qubit target)
        {
            ApplyUncontrolledRx__Body(-angle, target);
        }
    }
}

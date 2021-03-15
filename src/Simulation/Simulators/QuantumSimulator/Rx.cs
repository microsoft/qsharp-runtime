// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Intrinsic.Interfaces;

namespace Microsoft.Quantum.Simulation.Simulators
{
    public partial class QuantumSimulator
    {
        void IIntrinsicRx.Body(double angle, Qubit target)
        {
            this.CheckQubit(target, nameof(target));
            CheckAngle(angle);
            R(this.Id, Pauli.PauliX, angle, (uint)target.Id);
        }

        void IIntrinsicRx.AdjointBody(double angle, Qubit target)
        {
            ((IIntrinsicRx)this).Body(-angle, target);
        }

        void IIntrinsicRx.ControlledBody(IQArray<Qubit> controls, double angle, Qubit target)
        {
            this.CheckQubits(controls, target);
            CheckAngle(angle);
            MCR(this.Id, Pauli.PauliX, angle, (uint)controls.Length, controls.GetIds(), (uint)target.Id);
        }

        void IIntrinsicRx.ControlledAdjointBody(IQArray<Qubit> controls, double angle, Qubit target)
        {
            ((IIntrinsicRx)this).ControlledBody(controls, -angle, target);
        }
    }
}

// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Intrinsic.Interfaces;

namespace Microsoft.Quantum.Simulation.Simulators
{
    public partial class QuantumSimulator
    {
        void IIntrinsicRy.Body(double angle, Qubit target)
        {
            this.CheckQubit(target, nameof(target));
            CheckAngle(angle);
            R(this.Id, Pauli.PauliY, angle, (IntPtr)target.Id);
        }

        void IIntrinsicRy.AdjointBody(double angle, Qubit target)
        {
            ((IIntrinsicRy)this).Body(-angle, target);
        }

        void IIntrinsicRy.ControlledBody(IQArray<Qubit> controls, double angle, Qubit target)
        {
            this.CheckQubits(controls, target);
            CheckAngle(angle);
            MCR(this.Id, Pauli.PauliY, angle, (uint)controls.Length, controls.GetIds(), (IntPtr)target.Id);
        }

        void IIntrinsicRy.ControlledAdjointBody(IQArray<Qubit> controls, double angle, Qubit target)
        {
            ((IIntrinsicRy)this).ControlledBody(controls, -angle, target);
        }
    }
}

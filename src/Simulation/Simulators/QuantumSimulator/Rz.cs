// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Intrinsic.Interfaces;

namespace Microsoft.Quantum.Simulation.Simulators
{
    public partial class QuantumSimulator
    {
        void IIntrinsicRz.Body(double angle, Qubit target)
        {
            this.CheckQubit(target, nameof(target));
            CheckAngle(angle);
            R(this.Id, Pauli.PauliZ, angle, (IntPtr)target.Id);
        }

        void IIntrinsicRz.AdjointBody(double angle, Qubit target)
        {
            ((IIntrinsicRz)this).Body(-angle, target);
        }

        void IIntrinsicRz.ControlledBody(IQArray<Qubit> controls, double angle, Qubit target)
        {
            this.CheckQubits(controls, target);
            CheckAngle(angle);
            MCR(this.Id, Pauli.PauliZ, angle, (uint)controls.Length, controls.GetIds(), (IntPtr)target.Id);
        }

        void IIntrinsicRz.ControlledAdjointBody(IQArray<Qubit> controls, double angle, Qubit target)
        {
            ((IIntrinsicRz)this).ControlledBody(controls, -angle, target);
        }
    }
}

// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.Runtime.InteropServices;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Simulation.Simulators
{
    public partial class QuantumSimulator
    {
        public virtual void ApplyUncontrolledRy_Body(double angle, Qubit target)
        {
            this.CheckQubit(target, nameof(target));
            CheckAngle(angle);
            R(this.Id, Pauli.PauliY, angle, (uint)target.Id);
        }

        public virtual void ApplyUncontrolledRy_AdjointBody(double angle, Qubit target)
        {
            ApplyUncontrolledRy_Body(-angle, target);
        }
    }
}

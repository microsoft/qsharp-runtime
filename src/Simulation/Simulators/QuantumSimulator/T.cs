// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.Runtime.InteropServices;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Simulation.Simulators
{
    public partial class QuantumSimulator
    {
        public virtual void T_Body(Qubit target)
        {
            this.CheckQubit(target);

            T(this.Id, (uint)target.Id);
        }

        public virtual void T_ControlledBody(IQArray<Qubit> controls, Qubit target)
        {
            this.CheckQubits(controls, target);

            SafeControlled(controls,
                () => T_Body(target),
                (count, ids) => MCT(this.Id, count, ids, (uint)target.Id));
        }

        public virtual void T_AdjointBody(Qubit target)
        {
            this.CheckQubit(target);

            AdjT(this.Id, (uint)target.Id);
        }

        public virtual void T_ControlledAdjointBody(IQArray<Qubit> controls, Qubit target)
        {
            this.CheckQubits(controls, target);

            SafeControlled(controls,
                () => T_AdjointBody(target),
                (count, ids) => MCAdjT(this.Id, count, ids, (uint)target.Id));
        }
    }
}

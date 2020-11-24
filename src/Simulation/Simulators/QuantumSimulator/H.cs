// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.Runtime.InteropServices;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Simulation.Simulators
{
    public partial class QuantumSimulator
    {
        public virtual void H_Body(Qubit target)
        {
            this.CheckQubit(target);

            H(this.Id, (uint)target.Id);
        }

        public virtual void H_ControlledBody(IQArray<Qubit> controls, Qubit target)
        {
            this.CheckQubits(controls, target);

            SafeControlled(controls,
                () => H_Body(target),
                (count, ids) => MCH(this.Id, count, ids, (uint)target.Id));
        }
    }
}

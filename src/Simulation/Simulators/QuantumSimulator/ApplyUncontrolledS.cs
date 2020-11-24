// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.Runtime.InteropServices;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Simulation.Simulators
{
    public partial class QuantumSimulator
    {
        public virtual void ApplyUncontrolledS_Body(Qubit target)
        {
            this.CheckQubit(target);

            S(this.Id, (uint)target.Id);
        }

        public virtual void ApplyUncontrolledS_AdjointBody(Qubit target)
        {
            this.CheckQubit(target);

            AdjS(this.Id, (uint)target.Id);
        }
    }
}

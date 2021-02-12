// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Simulation.Simulators
{
    public partial class QuantumSimulator
    {
        public virtual void ApplyUncontrolledT__Body(Qubit target)
        {
            this.CheckQubit(target);

            T(this.Id, (uint)target.Id);
        }

        public virtual void ApplyUncontrolledT__AdjointBody(Qubit target)
        {
            this.CheckQubit(target);

            AdjT(this.Id, (uint)target.Id);
        }
    }
}

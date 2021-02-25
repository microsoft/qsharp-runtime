// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Simulation.Simulators
{
    public partial class QuantumSimulator
    {
        public virtual void ApplyUncontrolledH__Body(Qubit target)
        {
            this.CheckQubit(target);

            H(this.Id, (uint)target.Id);
        }
    }
}

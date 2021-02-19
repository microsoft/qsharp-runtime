// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Simulation.Simulators
{
    public partial class QuantumSimulator
    {
        public void Reset__Body(Qubit target)
        {
            // The native simulator doesn't have a reset operation, so simulate
            // it via an M follow by a conditional X.
            this.CheckQubit(target);
            var res = M(this.Id, (uint)target.Id);
            if (res == 1)
            {
                X(this.Id, (uint)target.Id);
            }
        }
    }
}

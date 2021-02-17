// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Simulation.Simulators
{
    public partial class QuantumSimulator
    {
        public virtual Result M__Body(Qubit target)
        {
            this.CheckQubit(target);
            //setting qubit as measured to allow for release
            target.IsMeasured = true;
            return M(this.Id, (uint)target.Id).ToResult();
        }
    }
}

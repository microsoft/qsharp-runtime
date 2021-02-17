// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Simulation.Simulators
{
    public partial class QuantumSimulator
    {
        public virtual void ApplyControlledZ__Body(Qubit control, Qubit target)
        {
            this.CheckQubits(new QArray<Qubit>(new Qubit[]{ control, target }));

            MCZ(this.Id, 1, new uint[]{(uint)control.Id}, (uint)target.Id);
        }
    }
}

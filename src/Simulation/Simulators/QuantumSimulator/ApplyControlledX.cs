// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.Runtime.InteropServices;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Simulation.Simulators
{
    public partial class QuantumSimulator
    {
        public virtual void ApplyControlledX_Body(Qubit control, Qubit target)
        {
            this.CheckQubits(new QArray<Qubit>(new Qubit[]{ control, target }));

            MCX(this.Id, 1, new uint[]{(uint)control.Id}, (uint)target.Id);
        }
    }
}

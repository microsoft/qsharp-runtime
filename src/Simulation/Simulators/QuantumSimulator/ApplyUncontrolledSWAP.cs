// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.Runtime.InteropServices;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Simulation.Simulators
{
    public partial class QuantumSimulator
    {
        public virtual void ApplyUncontrolledSWAP__Body(Qubit qubit1, Qubit qubit2)
        {
            this.CheckQubits(new QArray<Qubit>(new Qubit[]{ qubit1, qubit2 }));

            MCX(this.Id, 1, new uint[]{(uint)qubit1.Id}, (uint)qubit2.Id);
            MCX(this.Id, 1, new uint[]{(uint)qubit2.Id}, (uint)qubit1.Id);
            MCX(this.Id, 1, new uint[]{(uint)qubit1.Id}, (uint)qubit2.Id);
        }
    }
}

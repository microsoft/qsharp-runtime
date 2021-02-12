// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Simulation.Simulators
{
    public partial class QuantumSimulator
    {
        public virtual void ApplyUncontrolledSWAP__Body(Qubit qubit1, Qubit qubit2)
        {
            // Issue #44 (https://github.com/microsoft/qsharp-runtime/issues/44)
            // If/when the simulator provides access to the accelerated SWAP functionality,
            // this can be replaced with a call to that instead of MCX.

            this.CheckQubits(new QArray<Qubit>(new Qubit[]{ qubit1, qubit2 }));

            MCX(this.Id, 1, new uint[]{(uint)qubit1.Id}, (uint)qubit2.Id);
            MCX(this.Id, 1, new uint[]{(uint)qubit2.Id}, (uint)qubit1.Id);
            MCX(this.Id, 1, new uint[]{(uint)qubit1.Id}, (uint)qubit2.Id);
        }
    }
}

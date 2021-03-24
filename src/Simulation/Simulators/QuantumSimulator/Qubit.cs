// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using Microsoft.Quantum.Simulation.Common;
using Microsoft.Quantum.Simulation.Core;
using System;
using System.Diagnostics;

namespace Microsoft.Quantum.Simulation.Simulators
{
    public partial class QuantumSimulator : SimulatorBase, IDisposable
    {
        class QSimQubit : Qubit
        {
            [DebuggerBrowsable(DebuggerBrowsableState.Never)]
            private static Pauli[] PAULI_Z = new Pauli[] { Pauli.PauliZ };
        
            public QSimQubit(int id, uint simulatorId) : base(id)
            {
                this.SimulatorId = simulatorId;
            }

            public QSimQubit(int id, uint simulatorId, string label) : this(id, simulatorId) {
                this.Label = label;
            }

            [DebuggerBrowsable(DebuggerBrowsableState.Never)]
            public uint SimulatorId { get; }

            public double Probability => JointEnsembleProbability(this.SimulatorId, 1, PAULI_Z, new uint[] { (uint)this.Id });

            public string? Label {get; set;}
        }
    }
}

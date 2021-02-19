// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Simulation.Simulators
{
    public partial class QuantumSimulator
    {
        public class QSimrandom : Quantum.Intrinsic.Random
        {
            private uint SimulatorId { get; }

            public QSimrandom(QuantumSimulator m) : base(m)
            {
                this.SimulatorId = m.Id;
            }

            public override Func<IQArray<double>, Int64> __Body__ => (p) =>
            {
                return random_choice(this.SimulatorId, p.Length, p.ToArray());
            };
        }
    }
}

// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.Runtime.InteropServices;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Simulation.Simulators
{
    public partial class QuantumSimulator
    {
        public virtual Func<Qubit, QVoid> ApplyUncontrolledY_Body() => (q1) =>
        {
            this.CheckQubit(q1);

            Y(this.Id, (uint)q1.Id);

            return QVoid.Instance;
        };
    }
}

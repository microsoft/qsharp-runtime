// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.Diagnostics;
using System.Linq;
using System.Runtime.InteropServices;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Simulation.Simulators
{
    public partial class QuantumSimulator
    {
        public Func<Qubit, Result> M_Body() => (q) =>
        {
            this.CheckQubit(q);
            //setting qubit as measured to allow for release
            q.IsMeasured = true;
            return M(this.Id, (uint)q.Id).ToResult();
        };
    }
}

// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators.Implementation
{
    using System;
    using Microsoft.Quantum.Simulation.Core;

    public partial class QCTraceSimulatorImpl
    {
        public virtual Result Measure__Body(IQArray<Pauli> paulis, IQArray<Qubit> targets)
        {
            return this.Measure(paulis, targets);
        }
    }
}
